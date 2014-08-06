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


#pragma mark - State Machine Delegate

- (void)stateDidChange:(ACEStateManager *)stateManager
{
    NSLog(@"%@: changed state to %@.", self.requestId, stateManager.currentState);
}

@end
