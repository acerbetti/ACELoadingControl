//
//  ACEErrorRequest.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEErrorRequest.h"

@implementation ACEErrorRequest

- (void)loadRequest
{
    [super loadRequest];
    
    [self loadContentWithBlock:^(ACELoadingControl *loading) {
        NSLog(@"Loading init");
        
        [loading doneWithError:nil];
    }];
}

@end
