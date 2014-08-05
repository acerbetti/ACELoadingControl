//
//  ACELoadingRequest.h
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACELoadingControl.h"
#import "ACELoadingStateManager.h"

typedef void (^ACELoadingBlock)(ACELoadingControl *loading);


@protocol ACELoadingRequestDelegate <NSObject>

@optional
- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

@end


@interface ACELoadingRequest : NSObject<ACELoadingRequestDelegate, ACEStateManagerDelegate>

@property (nonatomic, weak) id<ACELoadingRequestDelegate> delegate;
@property (nonatomic, readonly) NSString *loadingState;

- (void)loadContentWithBlock:(ACELoadingBlock)block;
- (void)loadRequest NS_REQUIRES_SUPER;

- (void)addChildRequest:(ACELoadingRequest *)request;
- (void)removeChildRequest:(ACELoadingRequest *)request;

@end
