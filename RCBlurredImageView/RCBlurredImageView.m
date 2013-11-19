//
// RCBlurredImageView.m
//
// Created by Rich Cameron on 5/10/13.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.Copyright (c) 2013 Rich Cameron. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "RCBlurredImageView.h"

@implementation RCBlurredImageView
{
    UIImageView   *_imageView;
    UIImageView   *_blurredImageView;
}

- (id)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        [self setImage:image];
    }
  
    return self;
}

- (void)setImage:(UIImage *)image
{
    CGFloat scale = 1;//[UIScreen mainScreen].scale;
    self.bounds = CGRectMake(0,0,image.size.width*scale,image.size.height*scale);
    _image = image;
    [self setup];
}

////////////////////////////////////////////////////////
- (void)setup
{
    // Set up regular image
    _imageView = [[UIImageView alloc] initWithImage:_image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = self.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight;
    if (!_imageView.superview)
        [self insertSubview:_imageView atIndex:0];
    
    // Set blurred image
    _blurredImageView = [[UIImageView alloc] initWithImage:[RCBlurredImageView blurredImage:_image]];
    _blurredImageView.contentMode = UIViewContentModeScaleAspectFit;
    _blurredImageView.frame = self.bounds;
    _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                       | UIViewAutoresizingFlexibleHeight;
    if (!_blurredImageView.superview)
        [self insertSubview:_blurredImageView atIndex:1];
    
    // Need to UI7Kit work properly https://github.com/youknowone/UI7Kit/issues/128
    self.backgroundColor = [UIColor colorWithPatternImage:_blurredImageView.image];
}

+ (UIImage *)applyBlur:(UIImage *)image
                radius:(CGFloat)blurRadius
                 times:(int)times
{
    CGRect imageRect = { CGPointZero, image.size };
    UIImage *effectImage = image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(effectInContext, 1.0, -1.0);
    CGContextTranslateCTM(effectInContext, 0, -image.size.height);
    CGContextDrawImage(effectInContext, imageRect, image.CGImage);
    
    vImage_Buffer effectInBuffer;
    effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
    effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
    effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
    effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
    
    vImage_Buffer effectOutBuffer;
    effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
    effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
    effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
    effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
    
    CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
    NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
    radius |= 1;
    
    for (int i = 0; i < times/2; i++)
    {
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    }
    
    
    CGColorSpaceRef colSp = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colSp, (__bridge CFArrayRef)@[(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9].CGColor], 0);
    
    CGContextDrawRadialGradient((times % 2 == 1) ? effectOutContext : effectInContext, gradient,
                                CGPointMake(CGRectGetMidX(imageRect),CGRectGetMidY(imageRect)), 0,
                                CGPointMake(CGRectGetMidX(imageRect),CGRectGetMidY(imageRect)), ceil(sqrt(imageRect.size.width*imageRect.size.width+imageRect.size.height*imageRect.size.height)/[UIScreen mainScreen].scale), 0);
    
    CGColorSpaceRelease(colSp);
    CGGradientRelease(gradient);
    
    if (times % 2 == 1)
    {
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        effectImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    if (times % 2 == 0)
        effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return effectImage;
}

// Description: Returns a Gaussian blurred version of _image
+ (UIImage *)blurredImage:(UIImage *)img
{
    return [RCBlurredImageView applyBlur:img radius:5 times:2];
}

// Description: Changes the opacity on the blurred image to change intensity
- (void)setBlurIntensity:(CGFloat)blurIntensity
{
    _blurIntensity = MAX(0.f,MIN(1.f,blurIntensity));
    [_blurredImageView setAlpha:_blurIntensity];
}

@end
