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


#import "ACELoadingControl.h"
#import "ACELoadingStateManager.h"

@interface ACELoadingControl ()
@property (nonatomic, copy) void (^block)(NSString *newState, NSError *error, ACELoadingUpdateBlock update);
@end

#pragma mark -

@implementation ACELoadingControl

+ (instancetype)loadingWithCompletionHandler:(void(^)(NSString *state, NSError *error, ACELoadingUpdateBlock update))handler
{
    NSParameterAssert(handler != nil);
    ACELoadingControl *loading = [[self alloc] init];
    loading.block = handler;
    loading.current = YES;
    return loading;
}

- (void)ignore
{
    [self doneWithNewState:nil error:nil update:nil];
}

- (void)done
{
    [self doneWithNewState:ACELoadingStateContentLoaded error:nil update:nil];
}

- (void)doneWithError:(NSError *)error
{
    NSString *newState = error ? ACELoadingStateError : ACELoadingStateContentLoaded;
    [self doneWithNewState:newState error:error update:nil];
}

- (void)updateWithContent:(ACELoadingUpdateBlock)update
{
    [self doneWithNewState:ACELoadingStateContentLoaded error:nil update:update];
}

- (void)updateWithNoContent:(ACELoadingUpdateBlock)update
{
    [self doneWithNewState:ACELoadingStateNoContent error:nil update:update];
}


#pragma mark - Helpers

- (void)doneWithNewState:(NSString *)newState error:(NSError *)error update:(ACELoadingUpdateBlock)update
{
    void (^block)(NSString *state, NSError *error, ACELoadingUpdateBlock update) = _block;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        block(newState, error, update);
    });
    
    _block = nil;
}


@end
