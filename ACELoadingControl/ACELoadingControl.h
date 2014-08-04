//
//  ACELoadingControl.h
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ACELoadingUpdateBlock)(id object);

@interface ACELoadingControl : NSObject

@property (nonatomic, getter=isCurrent) BOOL current;

+ (instancetype)loadingWithCompletionHandler:(void(^)(NSString *state, NSError *error, ACELoadingUpdateBlock update))handler;

/// Signals that this result should be ignored. Sends a nil value for the state to the completion handler.
- (void)ignore;

/// Signals that loading is complete with no errors. This triggers a transition to the Loaded state.
- (void)done;

/// Signals that loading failed with an error. This triggers a transition to the Error state.
- (void)doneWithError:(NSError *)error;

/// Signals that loading is complete, transitions into the Loaded state and then runs the update block.
- (void)updateWithContent:(ACELoadingUpdateBlock)update;

/// Signals that loading completed with no content, transitions to the No Content state and then runs the update block.
- (void)updateWithNoContent:(ACELoadingUpdateBlock)update;

@end
