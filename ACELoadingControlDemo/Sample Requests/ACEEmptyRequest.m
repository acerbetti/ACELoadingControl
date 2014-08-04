//
//  ACEEmptyRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEEmptyRequest.h"

@implementation ACEEmptyRequest

- (void)loadRequest
{
    [super loadRequest];
    
    [self loadContentWithBlock:^(ACELoadingControl *loading) {
        NSLog(@"Loading init");
        
        [loading updateWithNoContent:^(id object) {
            NSLog(@"Content loaded, no results");
        }];
    }];
}

@end
