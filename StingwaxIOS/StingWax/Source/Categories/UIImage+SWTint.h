//
//  UIImage+Tint.h
//
//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import <UIKit/UIKit.h>

@interface UIImage (SWTint)

- (UIImage *)sw_imageTintedWithColor:(UIColor *)color;
- (UIImage *)sw_imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
- (UIImage *)sw_imageTintedWithScreenBlend:(UIColor *)color fraction:(CGFloat)fraction;


+ (UIImage * _Nullable)animatedImageWithAnimatedGIFData:(NSData * _Nonnull)theData;
+ (UIImage * _Nullable)animatedImageWithAnimatedGIFURL:(NSURL * _Nonnull)theURL;


@end

