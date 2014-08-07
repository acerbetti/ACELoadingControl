// ACELoadingControl.h
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
