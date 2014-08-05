//
//  ACERootRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACERootRequest.h"

@implementation ACERootRequest

- (void)loadRequest
{
    [super loadRequest];
}

- (void)loadingRequest:(ACELoadingRequest *)request loadingWithState:(NSString *)state
{
    
}

- (void)notifyContentLoadedWithError:(NSError *)error
{
    NSLog(@"Parent: content loaded notification.");
}


#pragma mark - State Machine Delegate

- (void)stateDidChange:(ACEStateManager *)stateManager
{
    NSLog(@"Parent: changed state to %@.", stateManager.currentState);
}

@end
