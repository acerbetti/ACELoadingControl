// ACELoadingRequest.m
//
// Copyright (c) 2014 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ACELoadingRequest.h"

NSString *const kACELoadingState = @"loadingState";

@interface ACELoadingRequest ()
@property (nonatomic, strong) ACELoadingStateManager *stateMachine;
@property (nonatomic, strong) ACELoadingControl *loadingInstance;

@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@property (nonatomic, strong) NSError *loadingError;
@property (nonatomic, assign) BOOL loadingComplete;

@property (nonatomic, strong) ACELoadingRequest *parentRequest;
@property (nonatomic, strong) NSMutableSet *childRequests;
@end

#pragma mark -

@implementation ACELoadingRequest {
    NSString *_requestId;
}

- (instancetype)initWithRequestId:(NSString *)requestId
{
    self = [super init];
    if (self) {
        _requestId = requestId;
        
        // set the initial state
        self.stateMachine.currentState = [self initialState];
    }
    return self;
}

- (NSString *)initialState
{
    return ACELoadingStateInitial;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Loading request %@ with state: %@", _requestId, self.loadingState];
}

- (void)dealloc
{
    for (ACELoadingRequest *request in self.childRequests) {
        [self removeChildRequest:request];
    }
}


#pragma mark - Properties

- (NSMutableSet *)childRequests
{
    if (_childRequests == nil) {
        _childRequests = [NSMutableSet set];
    }
    return _childRequests;
}

- (ACELoadingStateManager *)stateMachine
{
    if (_stateMachine == nil) {
        _stateMachine = [ACELoadingStateManager new];
        _stateMachine.delegate = self;
    }
    return _stateMachine;
}

- (NSString *)loadingState
{
    return self.stateMachine.currentState;
}

- (NSString *)requestId
{
    return _requestId;
}


#pragma mark - Actions

- (void)loadRequest
{
    [self beginLoading];
    
    for (ACELoadingRequest *request in self.childRequests) {
        [request loadRequest];
    }
}

- (void)loadContentWithBlock:(ACELoadingBlock)block
{
    __weak typeof(self) weakSelf = self;
    
    ACELoadingControl *loading = [ACELoadingControl loadingWithCompletionHandler:^(NSString *newState, NSError *error, ACELoadingUpdateBlock update) {
        if (newState != nil) {
            [self endLoadingWithState:newState error:error update:^{
                if (update != nil) {
                    update(weakSelf);
                }
            }];
        }
    }];
    
    // Tell previous loading instance it's no longer current and remember this loading instance
    self.loadingInstance.current = NO;
    self.loadingInstance = loading;
    
    // Call the provided block to actually do the load
    block(loading);
}

- (void)beginLoading
{
    // update the status
    [self updateLoadingState];
    
    self.loadingComplete = NO;
    
    NSString *currentState = [self loadingState];
    if ([currentState isEqualToString:ACELoadingStateInitial] || [currentState isEqualToString:ACELoadingStateLoadingContent]) {
        [self.stateMachine applyState:ACELoadingStateLoadingContent];
        
    } else {
        [self.stateMachine applyState:ACELoadingStateRefreshingContent];
    }
    
    [self notifyWillLoadContent];
}

- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingComplete = YES;
    self.loadingError = error;
    
    [self.stateMachine applyState:state];
    
    if (self.shouldDisplayPlaceholder) {
        if (update) {
            [self enqueuePendingUpdateBlock:update];
        }
        
    } else {
        [self executeBatchUpdate:^{
            // run pending updates
            [self executePendingUpdates];
            
            if (update) {
                update();
            }
            
        } complete:nil];
    }
    
    [self notifyContentLoadedWithError:error];
}

- (BOOL)shouldDisplayPlaceholder
{
    // Only display a placeholder when we're loading or have no content
    NSString *loadingState = self.loadingState;
    if (![loadingState isEqualToString:ACELoadingStateLoadingContent] && ![loadingState isEqualToString:ACELoadingStateNoContent])
        return NO;
    
    return YES;
}


#pragma mark - KVO

- (void)stateWillChange:(ACEStateManager *)stateManager
{
    [self willChangeValueForKey:@"loadingState"];
}

- (void)stateDidChange:(ACEStateManager *)stateManager
{
    [self didChangeValueForKey:@"loadingState"];
}


#pragma mark - Dependencies

- (void)addChildRequest:(ACELoadingRequest *)request
{
    if (request != nil) {
        // set the parent request
        request.parentRequest = self;
        
        // add to the list of children
        [self.childRequests addObject:request];
    }
}

- (void)removeChildRequest:(ACELoadingRequest *)request
{
    if (request != nil) {
        // remove the parent request
        request.parentRequest = self;
        
        // remove from the list of children
        [self.childRequests removeObject:request];
    }
}

- (void)requestWillLoadContent:(ACELoadingRequest *)request
{
    // update the status
    [self updateLoadingState];
    
    // update the parent status
    [self notifyWillLoadContent];
}

- (void)request:(ACELoadingRequest *)request didLoadContentWithError:(NSError *)error
{
    BOOL showingPlaceholder = self.shouldDisplayPlaceholder;
    [self updateLoadingState];
    
    // we were showing the placehoder and now we're not
    if (showingPlaceholder && !self.shouldDisplayPlaceholder) {
        [self executeBatchUpdate:^{
            [self executePendingUpdates];
            
        } complete:nil];
    }
    
    // update the parent status
    [self notifyContentLoadedWithError:error];
}

- (void)updateLoadingState
{
    NSSet *loadingStates = [self.childRequests valueForKey:@"loadingState"];
    if (loadingStates.count == 0) {
        return;
    }
    
    // let's find out what our state should be by asking our data sources
    NSInteger numberOfLoading = 0;
    NSInteger numberOfRefreshing = 0;
    NSInteger numberOfError = 0;
    NSInteger numberOfLoaded = 0;
    NSInteger numberOfNoContent = 0;
    
    for (NSString *state in loadingStates) {
        if ([state isEqualToString:ACELoadingStateLoadingContent])
            numberOfLoading++;
        
        else if ([state isEqualToString:ACELoadingStateRefreshingContent])
            numberOfRefreshing++;
        
        else if ([state isEqualToString:ACELoadingStateError])
            numberOfError++;
        
        else if ([state isEqualToString:ACELoadingStateContentLoaded])
            numberOfLoaded++;
        
        else if ([state isEqualToString:ACELoadingStateNoContent])
            numberOfNoContent++;
    }
    
    // Always prefer loading
    if (numberOfLoading) {
        [self.stateMachine applyState:ACELoadingStateLoadingContent];
        
    } else if (numberOfRefreshing) {
        [self.stateMachine applyState:ACELoadingStateRefreshingContent];
        
    } else if (numberOfError) {
        [self.stateMachine applyState:ACELoadingStateError];
        
    } else if (numberOfNoContent) {
        [self.stateMachine applyState:ACELoadingStateNoContent];
        
    } else if (numberOfLoaded) {
        [self.stateMachine applyState:ACELoadingStateContentLoaded];
        
    } else {
        [self.stateMachine applyState:ACELoadingStateInitial];
    }
}


#pragma mark - Notifications

- (void)executePendingUpdates
{
    dispatch_block_t block = self.pendingUpdateBlock;
    self.pendingUpdateBlock = nil;
    
    if (block) {
        block();
    }
}

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block
{
    dispatch_block_t update;
    
    if (self.pendingUpdateBlock) {
        dispatch_block_t oldPendingUpdate = self.pendingUpdateBlock;
        
        update = ^{
            oldPendingUpdate();
            block();
        };
        
    } else {
        update = block;
    }
    
    self.pendingUpdateBlock = update;
}

- (void)notifyWillLoadContent
{
    [self.parentRequest requestWillLoadContent:self];
}

- (void)executeBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    if (self.parentRequest != nil) {
        [self.parentRequest executeBatchUpdate:update complete:complete];
        
    } else {
        // execute all the updates together
        if (update) {
            update();
        }
        
        if (complete) {
            complete();
        }
    }
}

- (void)notifyContentLoadedWithError:(NSError *)error
{
    // notify the parent
    [self.parentRequest request:self didLoadContentWithError:error];
}

@end
