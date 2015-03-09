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

@implementation RCBlurredImageView
{
    UIImageView   *_imageView;
    UIImageView   *_blurredImageView;
}

#pragma mark - Init

- (id)initWithImage:(UIImage *)image
{
    if (self = [super initWithFrame:(CGRect){CGPointZero, image.size}]) {
        self.image = image;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self RCBlurredImageView_commonInit];
}

- (void)RCBlurredImageView_commonInit
{
    // Set up regular image
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _imageView.translatesAutoresizingMaskIntoConstraints = YES;
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
    } else {
        _imageView.image = _image;
    }
    
    // Set blurred image
    if (_blurredImageView == nil) {
        _blurredImageView = [[UIImageView alloc] initWithImage:[self blurredImage]];
        _blurredImageView.alpha = 0.f;
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurredImageView.translatesAutoresizingMaskIntoConstraints = YES;
        _blurredImageView.frame = self.bounds;
        [self addSubview:_blurredImageView];
    } else {
        _blurredImageView.image = [self blurredImage];
    }
    
    //NSLog(@"imageview frame = %@", NSStringFromCGRect(_imageView.frame));
    //NSLog(@"blurred frame = %@", NSStringFromCGRect(_blurredImageView.frame));
}


#pragma mark - Blur

- (UIImage *)blurredImage
{
    // Make sure that we have an image to work with
    if (!_image)
        return nil;
    
    if (_image.scale == 2) {
        _image = [UIImage imageWithCGImage:_image.CGImage scale:1 orientation:_image.imageOrientation];
    }
    
    // Create context
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // Create an image
    CIImage *image = [CIImage imageWithCGImage:_image.CGImage];
    
    // Set up a Gaussian Blur filter
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:image forKey:kCIInputImageKey];
    
    // Get blurred image out
    CIImage *blurredImage = [blurFilter valueForKey:kCIOutputImageKey];
    
    // Set up vignette filter
    CIFilter *vignetteFilter = [CIFilter filterWithName:@"CIVignette"];
    [vignetteFilter setValue:blurredImage forKey:kCIInputImageKey];
    [vignetteFilter setValue:@(4.f) forKey:@"InputIntensity"];
    
    // get vignette & blurred image
    CIImage *vignetteImage = [vignetteFilter valueForKey:kCIOutputImageKey];
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGImageRef imageRef = [context createCGImage:vignetteImage fromRect:(CGRect){CGPointZero, _image.size}];
    return [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
}

- (CGFloat)blurIntensity
{
    return _blurredImageView.alpha;
}

- (void)setBlurIntensity:(CGFloat)blurIntensity
{
    _blurredImageView.alpha = MAX(0.f,MIN(1.f,blurIntensity));
}

@end
