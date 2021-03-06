//
//  ACEViewController.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"

#import "ACEDataRequest.h"
#import "ACEEmptyRequest.h"
#import "ACEErrorRequest.h"
#import "ACERootRequest.h"

@interface ACEViewController ()
@property (nonatomic, strong) ACERootRequest *requestWithData;
@end

@implementation ACEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // parent
    self.requestWithData = [[ACERootRequest alloc] initWithRequestId:@"Root"];
    [self.requestWithData addObserver:self
           forKeyPath:@"loadingState"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    ACERootRequest *child = [[ACERootRequest alloc] initWithRequestId:@"Child B"];
    [child addChildRequest:[[ACEDataRequest alloc] initWithRequestId:@"Child B.1"]];
    [child addChildRequest:[[ACEDataRequest alloc] initWithRequestId:@"Child B.2"]];
    [child addChildRequest:[[ACEDataRequest alloc] initWithRequestId:@"Child B.4"]];
    
    // childrens
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithRequestId:@"Child A"]];
    [self.requestWithData addChildRequest:child];
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithRequestId:@"Child C"]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@: changed state to %@.", @"PAGE", change[@"new"]);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender
{
    // start
    [self.requestWithData loadRequest];
}

@end
