//
//  ACELoadingRequest.h
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/4/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACELoadingControl.h"

typedef void (^ACELoadingBlock)(ACELoadingControl *loading);


@protocol ACELoadingRequestDelegate <NSObject>

@optional
- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

@end





@interface ACELoadingRequest : NSObject<ACELoadingRequestDelegate>

@property (nonatomic, weak) id<ACELoadingRequestDelegate> delegate;

- (void)loadContentWithBlock:(ACELoadingBlock)block;

@end
