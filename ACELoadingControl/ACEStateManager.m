// ACEStateManager.m
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


#import "ACEStateManager.h"

#import <objc/message.h>
#import <libkern/OSAtomic.h>

@implementation ACEStateManager {
    OSSpinLock _lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (BOOL)applyState:(NSString *)toState
{
    NSString *fromState = self.currentState;
    
    NSString *appliedToState = [self validateTransitionFromState:fromState toState:toState];
    if (!appliedToState)
        return NO;
    
    // ...send will-change message for downstream KVO support...
    id target = [self target];
    
    if ([target respondsToSelector:@selector(stateWillChange:)]) {
        [target stateWillChange:self];
    }
    
    OSSpinLockLock(&_lock);
    _currentState = [appliedToState copy];
    OSSpinLockUnlock(&_lock);
    
    // ... send messages
    [self performTransitionFromState:fromState toState:appliedToState];
    
    return [toState isEqual:appliedToState];
}


#pragma mark - Helpers

- (id<ACEStateManagerDelegate>)target
{
    id<ACEStateManagerDelegate> delegate = self.delegate;
    if (delegate)
        return delegate;
    return self;
}

- (NSString *)validateTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    // Transitioning to the same state (fromState == toState) is always allowed. If it's explicitly included in its own validTransitions, the standard method calls below will be invoked. This allows us to avoid creating states that exist only to reexecute transition code for the current state.
    
    // Raise exception if attempting to transition to nil -- you can only transition *from* nil
    if (!toState) {
        toState = [self stateManager:self missingTransitionFromState:fromState toState:toState];
        if (!toState) {
            return nil;
        }
    }
    
    // Raise exception if this is an illegal transition (toState must be a validTransition on fromState)
    if (fromState) {
        id validTransitions = self.validTransitions[fromState];
        BOOL transitionSpecified = YES;
        
        // Multiple valid transitions
        if ([validTransitions isKindOfClass:[NSArray class]]) {
            if (![validTransitions containsObject:toState]) {
                transitionSpecified = NO;
            }
        }
        // Otherwise, single valid transition object
        else if (![validTransitions isEqual:toState]) {
            transitionSpecified = NO;
        }
        
        if (!transitionSpecified) {
            // Silently fail if implict transition to the same state
            if ([fromState isEqualToString:toState]) {
                return nil;
            }
            
            toState = [self stateManager:self missingTransitionFromState:fromState toState:toState];
            if (!toState)
                return nil;
        }
    }
    
    // Allow target to opt out of this transition (preconditions)
    id target = [self target];
    typedef BOOL (*ObjCMsgSendReturnBool)(id, SEL);
    ObjCMsgSendReturnBool sendMsgReturnBool = (ObjCMsgSendReturnBool)objc_msgSend;
    
    SEL enterStateAction = NSSelectorFromString([@"shouldEnter" stringByAppendingString:toState]);
    if ([target respondsToSelector:enterStateAction] && !sendMsgReturnBool(target, enterStateAction)) {
        toState = [self stateManager:self missingTransitionFromState:fromState toState:toState];
    }
    
    return toState;
}

- (void)performTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    id target = [self target];
    
    typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
    ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
    
    if (fromState) {
        SEL exitStateAction = NSSelectorFromString([@"didExit" stringByAppendingString:fromState]);
        if ([target respondsToSelector:exitStateAction]) {
            sendMsgReturnVoid(target, exitStateAction);
        }
    }
    
    SEL enterStateAction = NSSelectorFromString([@"didEnter" stringByAppendingString:toState]);
    if ([target respondsToSelector:enterStateAction]) {
        sendMsgReturnVoid(target, enterStateAction);
    }
    
    NSString *fromStateNotNil = fromState ? fromState : @"Nil";
    
    SEL transitionAction = NSSelectorFromString([NSString stringWithFormat:@"stateDidChangeFrom%@To%@", fromStateNotNil, toState]);
    if ([target respondsToSelector:transitionAction]) {
        sendMsgReturnVoid(target, transitionAction);
    }
    
    if ([target respondsToSelector:@selector(stateDidChange:)]) {
        [target stateDidChange:self];
    }
}


#pragma mark - Error handler

- (NSString *)stateManager:(ACEStateManager *)stateManager missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    NSString *missingState = nil;
    
    if ([self.delegate respondsToSelector:@selector(stateManager:missingTransitionFromState:toState:)]) {
        missingState = [self.delegate stateManager:self missingTransitionFromState:fromState toState:toState];
    }
    
    if (missingState == nil) {
        [NSException raise:@"IllegalStateTransition" format:@"cannot transition from %@ to %@", fromState, toState];
    }
    
    return missingState;
}

@end
