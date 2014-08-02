//
//  ACELoadingControl.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACELoadingControl.h"
#import "ACELoadingStateManager.h"

@interface ACELoadingControl ()
@property (nonatomic, copy) void (^block)(NSString *newState, NSError *error, ACELoadingUpdateBlock update);
@end

#pragma mark -

@implementation ACELoadingControl

+ (instancetype)loadingWithCompletionHandler:(void(^)(NSString *state, NSError *error, ACELoadingUpdateBlock update))handler
{
    NSParameterAssert(handler != nil);
    ACELoadingControl *loading = [[self alloc] init];
    loading.block = handler;
    loading.current = YES;
    return loading;
}

- (void)ignore
{
    [self doneWithNewState:nil error:nil update:nil];
}

- (void)done
{
    [self doneWithNewState:ACELoadingStateContentLoaded error:nil update:nil];
}

- (void)doneWithError:(NSError *)error
{
    NSString *newState = error ? ACELoadingStateError : ACELoadingStateContentLoaded;
    [self doneWithNewState:newState error:error update:nil];
}

- (void)updateWithContent:(ACELoadingUpdateBlock)update
{
    [self doneWithNewState:ACELoadingStateContentLoaded error:nil update:update];
}

- (void)updateWithNoContent:(ACELoadingUpdateBlock)update
{
    [self doneWithNewState:ACELoadingStateNoContent error:nil update:update];
}


#pragma mark - Helpers

- (void)doneWithNewState:(NSString *)newState error:(NSError *)error update:(ACELoadingUpdateBlock)update
{
    void (^block)(NSString *state, NSError *error, ACELoadingUpdateBlock update) = _block;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        block(newState, error, update);
    });
    
    _block = nil;
}


@end
