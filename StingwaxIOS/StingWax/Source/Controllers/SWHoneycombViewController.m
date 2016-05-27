//
//  SWHoneycombViewController.m
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import "SWHoneycombViewController.h"

#import "SWHoneycombView.h"
#import "SWPolygonView.h"


@implementation SWHoneycombViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.honeycombView.isAnimating) {
        self.wasAnimatingHoneycombView = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.honeycombView stopAnimatingImmediately:YES];
    
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsUpdateConstraints];
    
    if (self.wasAnimatingHoneycombView) {
        self.wasAnimatingHoneycombView = NO;
        [self continueAnimatingHoneycomb];
    }
}

- (IBAction)startAnimatingHoneycomb
{
    [self.honeycombView startAnimatingImmediately:NO];
}

- (IBAction)continueAnimatingHoneycomb
{
    [self.honeycombView startAnimatingImmediately:YES];
}

- (IBAction)stopAnimatingHoneycomb
{
    [self.honeycombView stopAnimatingImmediately:NO];
}

@end
