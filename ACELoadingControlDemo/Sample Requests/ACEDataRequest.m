//
//  ACEDataRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEDataRequest.h"

@implementation ACEDataRequest {
    NSString *_name;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)loadRequest
{
    [super loadRequest];
    
    [self loadContentWithBlock:^(ACELoadingControl *loading) {
        NSLog(@"%@: loading...", _name);
        
        [loading updateWithContent:^(id object) {
            NSLog(@"%@: content loaded.", _name);
        }];
    }];
}


#pragma mark - State Machine Delegate

- (void)stateDidChange:(ACEStateManager *)stateManager
{
    NSLog(@"%@: changed state to %@.", _name, stateManager.currentState);
}

@end
