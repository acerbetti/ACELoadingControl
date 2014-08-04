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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender
{
    // parent
    self.requestWithData = [[ACERootRequest alloc] init];
    
    // childrens
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child A"]];
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child B"]];
    [self.requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child C"]];
    
    // start
    [self.requestWithData loadRequest];
}

@end
