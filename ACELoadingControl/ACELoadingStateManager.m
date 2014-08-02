//
//  ACELoadingStateManager.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACELoadingStateManager.h"

NSString * const ACELoadingStateInitial = @"Initial";
NSString * const ACELoadingStateLoadingContent = @"LoadingState";
NSString * const ACELoadingStateRefreshingContent = @"RefreshingState";
NSString * const ACELoadingStateContentLoaded = @"LoadedState";
NSString * const ACELoadingStateNoContent = @"NoContentState";
NSString * const ACELoadingStateError = @"ErrorState";

@implementation ACELoadingStateManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentState = ACELoadingStateInitial;
        self.validTransitions = @{
                                  ACELoadingStateInitial            : @[ACELoadingStateLoadingContent],
                                  ACELoadingStateLoadingContent     : @[ACELoadingStateContentLoaded, ACELoadingStateNoContent, ACELoadingStateError],
                                  ACELoadingStateRefreshingContent  : @[ACELoadingStateContentLoaded, ACELoadingStateNoContent, ACELoadingStateError],
                                  ACELoadingStateContentLoaded      : @[ACELoadingStateRefreshingContent, ACELoadingStateNoContent, ACELoadingStateError],
                                  ACELoadingStateNoContent          : @[ACELoadingStateRefreshingContent, ACELoadingStateContentLoaded, ACELoadingStateError],
                                  ACELoadingStateError              : @[ACELoadingStateLoadingContent, ACELoadingStateRefreshingContent, ACELoadingStateNoContent, ACELoadingStateContentLoaded]
                                  };
    }
    return self;
}

@end
