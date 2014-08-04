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
@property (nonatomic, assign) BOOL loadingComplete;
@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@end

#pragma mark -

@implementation ACELoadingRequest

#pragma mark - Properties

- (ACELoadingStateManager *)stateMachine
{
    if (_stateMachine == nil) {
        _stateMachine = [ACELoadingStateManager new];
    }
    return _stateMachine;
}

#pragma mark - Actions

- (void)loadContentWithBlock:(ACELoadingBlock)block
{
    [self beginLoading];
    
    __weak typeof(self) weakSelf = self;
    
    ACELoadingControl *loading = [ACELoadingControl loadingWithCompletionHandler:^(NSString *newState, NSError *error, ACELoadingUpdateBlock update) {
        if (!newState)
            return;
        
        [self endLoadingWithState:newState error:error update:^{
            if (update != nil)
                update(weakSelf);
        }];
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
    
    NSString *currentState = self.stateMachine.currentState;
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
    }
    else {
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
    return NO;
}

#pragma mark - Notifications

- (void)executePendingUpdates
{
    dispatch_block_t block = _pendingUpdateBlock;
    _pendingUpdateBlock = nil;
    
    if (block) {
        block();
    }
}

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block
{
    dispatch_block_t update;
    
    if (_pendingUpdateBlock) {
        dispatch_block_t oldPendingUpdate = _pendingUpdateBlock;
        
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
