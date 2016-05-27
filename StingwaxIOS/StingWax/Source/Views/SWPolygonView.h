//
//  SWPolygonView.h
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPolygonView : UIView

@property (nonatomic) NSInteger numSides;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) BOOL showsGradient;

- (void)setShowsGradient:(BOOL)showsGradient animationDuration:(NSTimeInterval)animationDuration;

@end
