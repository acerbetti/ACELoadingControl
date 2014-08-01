//
//  ACEStateManager.h
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACEStateManagerDelegate <NSObject>

@optional

// Completely generic state change hook
- (void)stateWillChange;
- (void)stateDidChange;

/// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

#pragma mark -

@interface ACEStateManager : NSObject<ACEStateManagerDelegate>

@property (atomic, copy) NSString *currentState;
@property (atomic, retain) NSDictionary *validTransitions;

@property (nonatomic, weak) id<ACEStateManagerDelegate> delegate;

/// set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass missingTransitionFromState, so, if you invoke this, you must also supply an missingTransitionFromState implementation that avoids raising exceptions.
- (BOOL)applyState:(NSString *)state;

@end
