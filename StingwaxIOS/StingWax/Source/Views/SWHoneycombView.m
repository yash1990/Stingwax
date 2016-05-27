//
//  SWHoneycombView.m
//  StingWax
//
//  Created by Tyler Prevost on 2/3/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import "SWHoneycombView.h"

#import "SWPolygonView.h"

#define DEFAULT_ROTATION_ANIMATION_STEP_COUNT           4
#define DEFAULT_ROTATION_SPEED                          1
#define DEFAULT_HONEYCOMB_SPACING                       5
#define DEFAULT_BOUNCE_AMOUNT                           1
#define DEFAULT_FORCE_ANIMATION                         NO

@interface SWHoneycombView ()
{
    NSNumber *_rotationAnimationStepCount;
    NSNumber *_rotationSpeed;
    NSNumber *_honeycombSpacing;
    NSNumber *_forceAnimation;
    NSNumber *_bounceAmount;
}

@property (weak, nonatomic) IBOutlet UIView *rotatingView;
@property (nonatomic) SWPolygonView *topHoneycomb;
@property (nonatomic) SWPolygonView *leftHoneycomb;
@property (nonatomic) SWPolygonView *rightHoneycomb;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL forceAnimation;

@property (copy, nonatomic) CAAnimation *animation;

@end


@implementation SWHoneycombView

@synthesize rotatingView = _rotatingView;
@synthesize tintColor = _honeycombColor;

#pragma mark - Getters

- (UIView *)rotatingView {
    if (!_rotatingView) {
        UIView *rotatingView = [[UIView alloc] initWithFrame:self.bounds];
        rotatingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        rotatingView.backgroundColor = [UIColor clearColor];
        self.rotatingView = rotatingView;
    }
    return _rotatingView;
}

- (NSInteger)rotationAnimationStepCount {
    if (!_rotationAnimationStepCount) {
        _rotationAnimationStepCount = @(DEFAULT_ROTATION_ANIMATION_STEP_COUNT);
    }
    return _rotationAnimationStepCount.integerValue;
}

- (CGFloat)rotationSpeed {
    if (!_rotationSpeed) {
        _rotationSpeed = @(DEFAULT_ROTATION_SPEED);
    }
    return _rotationSpeed.floatValue;
}

- (CGFloat)honeycombSpacing {
    if (!_honeycombSpacing) {
        _honeycombSpacing = @(DEFAULT_HONEYCOMB_SPACING);
    }
    return _honeycombSpacing.floatValue;
}

- (CGFloat)bounceAmount {
    if (!_bounceAmount) {
        _bounceAmount = @(DEFAULT_BOUNCE_AMOUNT);
    }
    return _bounceAmount.floatValue;
}

- (BOOL)forceAnimation {
    if (!_forceAnimation) {
        _forceAnimation = @(DEFAULT_FORCE_ANIMATION);
    }
    return _forceAnimation.boolValue;
}

- (UIView *)contentView {
    return self.rotatingView;
}

- (UIColor *)tintColor {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [super tintColor];
    }
    
    if (!_honeycombColor) {
        _honeycombColor = [UIColor whiteColor];
    }
    
    return _honeycombColor;
}


#pragma mark - Setters

- (void)setRotatingView:(UIView *)rotatingView {
    [_rotatingView removeFromSuperview];
    
    _rotatingView = rotatingView;
    
    if (_rotatingView) {
        [self addSubview:_rotatingView];
    }
}

- (void)setTopHoneycomb:(SWPolygonView *)topHoneycomb {
    [_topHoneycomb removeFromSuperview];
    
    _topHoneycomb = topHoneycomb;
    
    if (_topHoneycomb) {
        [self.rotatingView addSubview:_topHoneycomb];
    }
}

- (void)setLeftHoneycomb:(SWPolygonView *)leftHoneycomb {
    [_leftHoneycomb removeFromSuperview];
    
    _leftHoneycomb = leftHoneycomb;
    
    if (_leftHoneycomb) {
        [self.rotatingView addSubview:_leftHoneycomb];
    }
}

- (void)setRightHoneycomb:(SWPolygonView *)rightHoneycomb {
    [_rightHoneycomb removeFromSuperview];
    _rightHoneycomb = rightHoneycomb;
    if (_rightHoneycomb) {
        [self.rotatingView addSubview:_rightHoneycomb];
    }
}

- (void)setRotationAnimationStepCount:(NSInteger)rotationAnimationStepCount {
    rotationAnimationStepCount = MIN(4, rotationAnimationStepCount);
    _rotationAnimationStepCount = @(rotationAnimationStepCount);
}

- (void)setRotationSpeed:(CGFloat)rotationSpeed {
    _rotationSpeed = @(rotationSpeed);
}

- (void)setHoneycombSpacing:(CGFloat)honeycombSpacing {
    _honeycombSpacing = @(honeycombSpacing);
    
    [self setNeedsLayout];
}

- (void)setForceAnimation:(BOOL)forceAnimation {
    _forceAnimation = @(forceAnimation);
}

- (void)setBounceAmount:(CGFloat)bounceAmount {
    _bounceAmount = @(bounceAmount);
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    if (_isAnimating == isAnimating) {
        return;
    }
    
    _isAnimating = isAnimating;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [super setTintColor:tintColor];
        return;
    }
    
    _honeycombColor = tintColor;
    
    self.topHoneycomb.tintColor = _honeycombColor;
    self.leftHoneycomb.tintColor = _honeycombColor;
    self.rightHoneycomb.tintColor = _honeycombColor;
}


#pragma mark - Object Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupHoneycombs];
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHoneycombs];
    }
    return self;
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat honeycombSize = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) * 0.5;
    
    CGPoint selfCenter = CGPointMake(CGRectGetWidth(bounds) * 0.5, CGRectGetHeight(bounds) * 0.5);
    
    CGAffineTransform leftRotateTrans = CGAffineTransformMakeRotation(4 * M_PI / 3);
    CGAffineTransform rightRotateTrans = CGAffineTransformMakeRotation(2 * M_PI / 3);
    
    CGPoint topHoneycombCenter = CGPointMake(0, -(honeycombSize + self.honeycombSpacing) * 0.5);
    CGPoint leftHoneycombCenter = CGPointApplyAffineTransform(topHoneycombCenter, leftRotateTrans);
    CGPoint rightHoneycombCenter = CGPointApplyAffineTransform(topHoneycombCenter, rightRotateTrans);
    
    self.topHoneycomb.center = CGPointMake(topHoneycombCenter.x + selfCenter.x, topHoneycombCenter.y + selfCenter.y);
    self.leftHoneycomb.center = CGPointMake(leftHoneycombCenter.x + selfCenter.x, leftHoneycombCenter.y + selfCenter.y);
    self.rightHoneycomb.center = CGPointMake(rightHoneycombCenter.x + selfCenter.x, rightHoneycombCenter.y + selfCenter.y);
}


#pragma mark - Public Methods

- (void)startAnimatingImmediately:(BOOL)immediate
{
    if (!self.isAnimating) {
        if (immediate) {
            self.forceAnimation = YES;
        }
        [self rotateHoneycombsAndForceLinearCurve:immediate];
    }
}

- (void)stopAnimatingImmediately:(BOOL)immediate
{
    [self stopRotatingHoneycombsWithBounceAnimation:!immediate];
}


#pragma mark - Private Methods

- (void)setIsAnimating
{
    if (self.isAnimating == NO) {
        self.isAnimating = YES;
    }
}

- (void)setIsNotAnimating
{
    if (self.isAnimating == YES) {
        self.isAnimating = NO;
    }
}

- (void)setupHoneycombs
{
    CGFloat honeycombSize = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.5;
    CGRect honeycombBounds = CGRectMake(0, 0, honeycombSize, honeycombSize);
    
    SWPolygonView *topHoneycomb = [[SWPolygonView alloc] initWithFrame:honeycombBounds];
    SWPolygonView *leftHoneycomb = [[SWPolygonView alloc] initWithFrame:honeycombBounds];
    SWPolygonView *rightHoneycomb = [[SWPolygonView alloc] initWithFrame:honeycombBounds];
    
    topHoneycomb.numSides = leftHoneycomb.numSides = rightHoneycomb.numSides = 6;
    
    UIViewAutoresizing resizingMask = (UIViewAutoresizing)(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                                           UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    topHoneycomb.autoresizingMask = leftHoneycomb.autoresizingMask = rightHoneycomb.autoresizingMask = resizingMask;
    
    self.topHoneycomb = topHoneycomb;
    self.leftHoneycomb = leftHoneycomb;
    self.rightHoneycomb = rightHoneycomb;

    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        self.topHoneycomb.tintColor = self.tintColor;
        self.leftHoneycomb.tintColor = self.tintColor;
        self.rightHoneycomb.tintColor = self.tintColor;
    }
}

- (void)rotateHoneycombsAndForceLinearCurve:(BOOL)forceLinearCurve
{
    NSInteger count = self.rotationAnimationStepCount;
    NSTimeInterval duration = 2.0 / (count * self.rotationSpeed);
    CGFloat angle = 2 * M_PI / count;
    
    [self rotateHoneycombsWithStepCount:count
                               duration:duration
                                  angle:angle
                              transform:self.rotatingView.transform
                       forceLinearCurve:forceLinearCurve
                             completion:
    ^{
        [self rotateHoneycombsAndForceLinearCurve:YES];
    }];
}

- (void)rotateHoneycombsWithStepCount:(NSInteger)count
                             duration:(NSTimeInterval)duration
                                angle:(CGFloat)angle
                            transform:(CGAffineTransform)transform
                     forceLinearCurve:(BOOL)forceLinearCurve
                           completion:(void(^)(void))completion
{
    if (count == 0) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
        return;
    }
    
    [self setIsAnimating];
    
    UIViewAnimationOptions animationCurveOption = forceLinearCurve ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseIn;
    
    CGAffineTransform rotateTransform = CGAffineTransformRotate(transform, angle);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationCurveOption
                     animations:
    ^{
        self.rotatingView.transform = rotateTransform;
    } completion:^(BOOL finished) {
        
        if (!finished && !self.forceAnimation) {
            [self setIsNotAnimating];
            return;
        }
        
        self.forceAnimation = NO;
        
        [self rotateHoneycombsWithStepCount:count - 1
                                   duration:duration
                                      angle:angle
                                  transform:rotateTransform
                           forceLinearCurve:YES
                                 completion:completion];
    }];
}

- (void)stopRotatingHoneycombsWithBounceAnimation:(BOOL)doBounceAnimation
{
    if (!self.isAnimating) {
        return;
    }
    
    [self setIsNotAnimating];
    
    CGAffineTransform transform = ((CALayer *)self.rotatingView.layer.presentationLayer).affineTransform;
    [self.rotatingView.layer removeAllAnimations];
    self.rotatingView.transform = transform;
    
    if (!doBounceAnimation) {
        return;
    }
    
    CGFloat bounceAmount = self.bounceAmount;
    
    [UIView animateWithDuration:0.125/2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.rotatingView.transform = CGAffineTransformRotate(transform, bounceAmount * 5 * M_PI/180);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.25/2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.rotatingView.transform = CGAffineTransformRotate(transform, -bounceAmount * 3 * M_PI/180);
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.35/2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        self.rotatingView.transform = transform;
                    } completion:nil];
                }
            }];
        }
    }];
}

@end
