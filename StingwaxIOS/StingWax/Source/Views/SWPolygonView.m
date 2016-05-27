//
//  SWPolygonView.m
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWPolygonView.h"

#define DEFAULT_NUM_SIDES   6
#define MAX_NUM_SIDES       10000

@interface SWPolygonView ()
{
    NSNumber *_numSides;
    NSNumber *_rotation;
}

@property (nonatomic) CAGradientLayer *gradientLayer;

@end


@implementation SWPolygonView

@synthesize tintColor = _polygonColor;

#pragma mark - Getters

- (NSInteger)numSides
{
    if (!_numSides) {
        _numSides = @(DEFAULT_NUM_SIDES);
    }
    return _numSides.integerValue;
}

- (CGFloat)rotation
{
    if (!_rotation) {
        _rotation = @(0.0f);
    }
    return _rotation.floatValue;
}

- (UIColor *)tintColor
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [super tintColor];
    }
    
    if (!_polygonColor) {
        _polygonColor = [UIColor whiteColor];
    }
    return _polygonColor;
}


#pragma mark - Setters

- (void)setNumSides:(NSInteger)numSides
{
    numSides = MIN(MAX(numSides, 3), MAX_NUM_SIDES);
    
    _numSides = @(numSides);
    
    [self setNeedsDisplay];
}

- (void)setRotation:(CGFloat)rotation
{
    _rotation = @(rotation);
    
    [self setNeedsDisplay];
}

- (void)setGradientLayer:(CAGradientLayer *)gradientLayer
{
    [_gradientLayer removeFromSuperlayer];
    
    _gradientLayer = gradientLayer;
    
    if (gradientLayer) {
        [self.layer addSublayer:gradientLayer];
    }
}

- (void)setShowsGradient:(BOOL)showsGradient
{
    [self setShowsGradient:showsGradient animationDuration:0];
}

- (void)setShowsGradient:(BOOL)showsGradient animationDuration:(NSTimeInterval)animationDuration
{
    _showsGradient = showsGradient;
    
    [CATransaction setAnimationDuration:animationDuration];
    self.gradientLayer.opacity = showsGradient ? 1 : 0;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [super setTintColor:tintColor];
        return;
    }
    
    _polygonColor = tintColor;
}


#pragma mark - Object Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupGradientLayer];
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGradientLayer];
    }
    
    return self;
}


#pragma mark - Private Methods

- (void)setupGradientLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = self.bounds;
    gradientLayer.anchorPoint = CGPointMake(0, 0);
    gradientLayer.position = CGPointMake(0, 0);
    gradientLayer.cornerRadius = 12;
    gradientLayer.borderWidth = 2;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0.6f, 0.6f);
    gradientLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.opacity = 0;
    
    self.gradientLayer = gradientLayer;
}


#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gradientLayer.bounds = self.bounds;
}

- (void)tintColorDidChange
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat midX, midY, radius;
    
    midX = CGRectGetMidX(self.bounds);
    midY = CGRectGetMidY(self.bounds);
    radius = -MIN(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds)) * 0.5f;
    
    NSUInteger numSides = self.numSides;
    CGFloat rotation = self.rotation * M_PI / 180;
    
    CGAffineTransform rotateTrans = CGAffineTransformMakeRotation(rotation);
    CGPathMoveToPoint(path, &rotateTrans, 0, radius);
    
    for (NSUInteger i = 0; i < numSides; ++i) {
        rotateTrans = CGAffineTransformRotate(rotateTrans, 2 * M_PI / numSides);
        CGPathAddLineToPoint(path, &rotateTrans, 0, radius);
    }
    CGPathCloseSubpath(path);
    
    CGAffineTransform moveTrans = CGAffineTransformMakeTranslation(midX, midY);
    CGPathRef movedPath = CGPathCreateCopyByTransformingPath(path, &moveTrans);
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = movedPath;
    
    self.layer.mask = maskLayer;
    
    [self.tintColor setFill];
    
    CGContextAddPath(context, movedPath);
    CGContextFillPath(context);
    
    CGPathRelease(movedPath);
    CGPathRelease(path);
}


@end
