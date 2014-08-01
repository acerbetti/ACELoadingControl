//
//  ACELoadingStateManager.h
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEStateManager.h"

/// The initial state.
extern NSString *const ACELoadingStateInitial;

/// The first load of content.
extern NSString *const ACELoadingStateLoadingContent;

/// Subsequent loads after the first.
extern NSString *const AACELoadingStateRefreshingContent;

/// After content is loaded successfully.
extern NSString *const ACELoadingStateContentLoaded;

/// No content is available.
extern NSString *const ACELoadingStateNoContent;

/// An error occurred while loading content.
extern NSString *const ACELoadingStateError;

@interface ACELoadingStateManager : ACEStateManager

@end
