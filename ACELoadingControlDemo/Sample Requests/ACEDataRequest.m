//
//  ACEDataRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEDataRequest.h"

@implementation ACEDataRequest

- (void)loadRequest
{
    [super loadRequest];
    
    [self loadContentWithBlock:^(ACELoadingControl *loading) {
        NSLog(@"%@: loading...", self.requestId);
        
        [loading updateWithContent:^(id object) {
            NSLog(@"%@: content loaded.", self.requestId);
        }];
    }];
}


#pragma mark - State Machine Delegate

- (void)stateDidChange:(ACEStateManager *)stateManager
{
    NSLog(@"%@: changed state to %@.", self.requestId, stateManager.currentState);
}

@end
