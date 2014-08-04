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
    ACERootRequest *requestWithData = [[ACERootRequest alloc] init];
    
    // childrens
    [requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child A"]];
    [requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child B"]];
    [requestWithData addChildRequest:[[ACEDataRequest alloc] initWithName:@"Child C"]];
    
    // start
    [requestWithData loadRequest];
}

@end
