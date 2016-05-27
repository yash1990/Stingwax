//
//  SWHoneycombView.h
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWPolygonView;

@interface SWHoneycombView : UIView

// Readonly properties
@property (nonatomic, readonly) SWPolygonView *topHoneycomb;
@property (nonatomic, readonly) SWPolygonView *leftHoneycomb;
@property (nonatomic, readonly) SWPolygonView *rightHoneycomb;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) BOOL isAnimating;

// Configurable properties
@property (nonatomic) NSInteger rotationAnimationStepCount; // default is 4
@property (nonatomic) CGFloat rotationSpeed;                // default is 1
@property (nonatomic) CGFloat honeycombSpacing;             // default is 5
@property (nonatomic) CGFloat bounceAmount;                 // default is 1
@property (nonatomic) UIColor *tintColor;

- (void)startAnimatingImmediately:(BOOL)immediate;
- (void)stopAnimatingImmediately:(BOOL)immediate;

@end
