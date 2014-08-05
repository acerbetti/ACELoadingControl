// ACECoreDataManager.h
//
// Copyright (c) 2014 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>

@class ACEStateManager;

@protocol ACEStateManagerDelegate <NSObject>

@optional

// Completely generic state change hook
- (void)stateWillChange:(ACEStateManager *)stateManager;
- (void)stateDidChange:(ACEStateManager *)stateManager;

/// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
- (NSString *)stateManager:(ACEStateManager *)stateManager missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

#pragma mark -

@interface ACEStateManager : NSObject<ACEStateManagerDelegate>

@property (atomic, copy) NSString *currentState;
@property (atomic, retain) NSDictionary *validTransitions;

@property (nonatomic, weak) id<ACEStateManagerDelegate> delegate;

/// set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass missingTransitionFromState, so, if you invoke this, you must also supply an missingTransitionFromState implementation that avoids raising exceptions.
- (BOOL)applyState:(NSString *)state;

@end
