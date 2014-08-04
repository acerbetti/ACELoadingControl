//
//  ACELoadingRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACELoadingRequest.h"
#import "ACELoadingStateManager.h"

@interface ACELoadingRequest ()
@property (nonatomic, strong) ACELoadingStateManager *stateMachine;
@property (nonatomic, strong) ACELoadingControl *loadingInstance;

@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@property (nonatomic, assign) BOOL loadingComplete;

@property (nonatomic, strong) NSMutableSet *childRequests;
@end

#pragma mark -

@implementation ACELoadingRequest

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
    }
    return _stateMachine;
}

- (NSString *)loadingState
{
    return self.stateMachine.currentState;
}


#pragma mark - Actions

- (void)loadRequest
{
    for (ACELoadingRequest *request in self.childRequests) {
        [request loadRequest];
    }
}

- (void)loadContentWithBlock:(ACELoadingBlock)block
{
    [self beginLoading];
    
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
    self.loadingComplete = NO;
    
    NSString *currentState = [self loadingState];
    if ([currentState isEqualToString:ACELoadingStateInitial] || [currentState isEqualToString:ACELoadingStateLoadingContent]) {
        self.stateMachine.currentState = ACELoadingStateLoadingContent;
        
    } else {
        self.stateMachine.currentState = ACELoadingStateRefreshingContent;
    }
    
    [self notifyWillLoadContent];
}

- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
//    self.loadingError = error;
    self.stateMachine.currentState = state;

    if (self.shouldDisplayPlaceholder) {
        if (update) {
            [self enqueuePendingUpdateBlock:update];
        }
        
    } else {
        [self notifyBatchUpdate:^{
            // Run pending updates
            [self executePendingUpdates];
            
            if (update) {
                update();
            }
        } complete:nil];
    }

    self.loadingComplete = YES;
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


#pragma mark - Dependencies

- (void)addChildRequest:(ACELoadingRequest *)request
{
    if (request != nil) {
        // set the delegate to self to get the notifications
        request.delegate = self;
        
        // add to the list of children
        [self.childRequests addObject:request];
    }
}

- (void)removeChildRequest:(ACELoadingRequest *)request
{
    if (request != nil) {
        // reset the delegate
        request.delegate = self;
        
        // remove from the list of children
        [self.childRequests removeObject:request];
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
    if ([self.delegate respondsToSelector:@selector(notifyWillLoadContent)]) {
        [self.delegate notifyWillLoadContent];
    }
}

- (void)notifyContentLoadedWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(notifyContentLoadedWithError:)]) {
        [self.delegate notifyContentLoadedWithError:error];
    }
}

- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    if ([self.delegate respondsToSelector:@selector(notifyBatchUpdate:complete:)]) {
        [self.delegate notifyBatchUpdate:update complete:complete];
    
    } else {
        if (update) {
            update();
        }
        
        if (complete) {
            complete();
        }
    }
}

@end