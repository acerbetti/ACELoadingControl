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

@interface ACEViewController ()<ACELoadingRequestDelegate>
@property (nonatomic, strong) ACERootRequest *requestWithData;
@end

@implementation ACEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // parent
    self.requestWithData = [[ACERootRequest alloc] init];
    self.requestWithData.delegate = self;
    
    ACEDataRequest *child = [[ACEDataRequest alloc] initWithName:@"Child B"];
    [child addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child B.1"]];
    [child addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child B.2"]];
    [child addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child B.4"]];
    
    // childrens
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child A"]];
    [self.requestWithData addChildRequest:child];
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child C"]];
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
