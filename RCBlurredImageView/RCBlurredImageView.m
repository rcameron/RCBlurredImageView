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
  
  BOOL          _userInteractionEnabled;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Init
////////////////////////////////////////////////////////
- (id)initWithImage:(UIImage *)image
{
  // Make sure we have an image to work with
  if (!image)
    return nil;
  
  // Calculate frame size
  CGRect frame = (CGRect){CGPointZero, image.size};
  
  self = [super initWithFrame:frame];
  
  if (!self)
    return nil;
  
  // Pass along parameters
  _image = image;
  
  [self RCBlurredImageView_commonInit];
  
  return self;
}

////////////////////////////////////////////////////////
- (void)RCBlurredImageView_commonInit
{
  // Make sure we're not subclassed
  if ([self class] != [RCBlurredImageView class])
    return;
  
  // Set user interaction to NO
  [self setUserInteractionEnabled:NO];
  
  // Set up regular image
  _imageView = [[UIImageView alloc] initWithImage:_image];
  [self addSubview:_imageView];
  
  // Set blurred image
  _blurredImageView = [[UIImageView alloc] initWithImage:[self blurredImage]];
  [_blurredImageView setAlpha:0.95f];
  
  if (_blurredImageView)
    [self addSubview:_blurredImageView];
  
  NSLog(@"imageview frame = %@", NSStringFromCGRect(_imageView.frame));
  NSLog(@"blurred frame = %@", NSStringFromCGRect(_blurredImageView.frame));
}


////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Blur
////////////////////////////////////////////////////////
/*
========================
- (UIImage *)blurredImage
Description: Returns a Gaussian blurred version of _image
========================
*/
- (UIImage *)blurredImage
{
  // Make sure that we have an image to work with
  if (!_image)
    return nil;
  
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
  CGSize scaledSize = CGSizeMake(_image.size.width * scale, _image.size.height * scale);
  CGImageRef imageRef = [context createCGImage:vignetteImage fromRect:(CGRect){CGPointZero, scaledSize}];
  
  return [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
}

/*
========================
- (void)setBlurIntensity
Description: Changes the opacity on the blurred image to change intensity
========================
*/
- (void)setBlurIntensity:(CGFloat)blurIntensity
{
  if (blurIntensity < 0.f)
    blurIntensity = 0.f;
  else if (blurIntensity > 1.f)
    blurIntensity = 1.f;
  
  _blurIntensity = blurIntensity;
  
  [_blurredImageView setAlpha:blurIntensity];
}

////////////////////////////////////////////////////////
@end
