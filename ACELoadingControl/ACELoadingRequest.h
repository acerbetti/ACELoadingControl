// ACELoadingRequest.h
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

extern NSString *const kACELoadingState;

extern NSString *const kLoadingErrorDomain;
extern NSString *const kLoadingErrorMultiKey;

typedef void (^ACELoadingBlock)(ACELoadingControl *loading);


@interface ACELoadingRequest : NSObject<ACEStateManagerDelegate>

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, weak, readonly) ACELoadingRequest *parentRequest;

@property (nonatomic, readonly) NSString *loadingState;
@property (nonatomic, readonly) NSError *loadingError;
@property (nonatomic, readonly) BOOL loadingComplete;



- (instancetype)initWithRequestId:(NSString *)requestId;

- (NSString *)initialState;

- (void)loadContentWithBlock:(ACELoadingBlock)block;
- (void)loadRequest NS_REQUIRES_SUPER;

- (void)requestWillLoadContent:(ACELoadingRequest *)request;
- (void)request:(ACELoadingRequest *)request didLoadContentWithError:(NSError *)error;

- (void)addChildRequest:(ACELoadingRequest *)request;
- (void)removeChildRequest:(ACELoadingRequest *)request;

@end
