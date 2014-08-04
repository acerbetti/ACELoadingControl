//
//  ACEViewController.m
//  ACELoadingControlDemo
//
//  Created by Stefano Acerbetti on 8/1/14.
//  Copyright (c) 2014 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACELoadingRequest.h"

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
    ACELoadingRequest *request = [ACELoadingRequest new];
    [request loadContentWithBlock:^(ACELoadingControl *loading) {
        
        NSLog(@"Loading init");
        
        [loading updateWithContent:^(id object) {
            NSLog(@"Content loaded");
        }];
        
//        [loading updateWithNoContent:^(id object) {
//            NSLog(@"Content loaded, no results");
//        }];
    }];
}

@end
