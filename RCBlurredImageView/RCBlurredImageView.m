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

#import "RCBlurredImageView.h"
#import "UIImage+StackBlur.h"

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
    self.bounds = (CGRect){CGPointZero, image.size};
    _image = image;
    [self setup];
}

////////////////////////////////////////////////////////
- (void)setup
{
    // Set up regular image
    _imageView = [[UIImageView alloc] initWithImage:_image];
    _imageView.frame = self.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight;
    if (!_imageView.superview)
        [self addSubview:_imageView];
  
    // Set blurred image
    _blurredImageView = [[UIImageView alloc] initWithImage:[RCBlurredImageView blurredImage:_image]];
    _blurredImageView.frame = self.bounds;
    _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                       | UIViewAutoresizingFlexibleHeight;
    if (!_blurredImageView.superview)
        [self addSubview:_blurredImageView];
}

// Description: Returns a Gaussian blurred version of _image
+ (UIImage *)blurredImage:(UIImage *)img
{
    UIImage * bluredImg = [img stackBlur:20];
    
    // Create context
    CIContext *context = [CIContext contextWithOptions:nil];
  
    // Get blurred image out
    CIImage *blurredImage = [CIImage imageWithCGImage:bluredImg.CGImage];
  
    // Set up vignette filter
    CIFilter *vignetteFilter = [CIFilter filterWithName:@"CIVignette"];
    [vignetteFilter setValue:blurredImage forKey:kCIInputImageKey];
    [vignetteFilter setValue:@(4.f) forKey:@"InputIntensity"];
  
    // get vignette & blurred image
    CIImage *vignetteImage = [vignetteFilter valueForKey:kCIOutputImageKey];

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize scaledSize = CGSizeMake(img.size.width * scale, img.size.height * scale);
    CGImageRef imageRef = [context createCGImage:vignetteImage fromRect:(CGRect){CGPointZero, scaledSize}];
  
    return [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
}

// Description: Changes the opacity on the blurred image to change intensity
- (void)setBlurIntensity:(CGFloat)blurIntensity
{
    _blurIntensity = MAX(0.f,MIN(1.f,blurIntensity));
    [_blurredImageView setAlpha:_blurIntensity];
}

@end
