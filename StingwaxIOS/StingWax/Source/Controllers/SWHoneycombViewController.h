//
//  SWHoneycombViewController.m
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWBaseViewController.h"

@class SWHoneycombView;

@interface SWHoneycombViewController : SWBaseViewController

@property (nonatomic) IBOutlet SWHoneycombView *honeycombView;

@property (nonatomic) BOOL wasAnimatingHoneycombView;

@end
