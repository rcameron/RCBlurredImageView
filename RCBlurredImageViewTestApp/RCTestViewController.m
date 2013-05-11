//
//  RCTestViewController.m
//  RCBlurredImageViewTestApp
//
//  Created by Rich Cameron on 5/10/13.
//  Copyright (c) 2013 Rich Cameron. All rights reserved.
//

#import "RCTestViewController.h"
#import "RCBlurredImageView.h"

@interface RCTestViewController ()

@end

@implementation RCTestViewController
{
  RCBlurredImageView    *_blurredImageView;
  BOOL                  _increaseBlur;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (!self)
    return nil;
  
  return self;
}

////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];

  // Create blurred image view
  _blurredImageView = [[RCBlurredImageView alloc] initWithImage:[UIImage imageNamed:@"test.jpg"]];
  [_blurredImageView setBlurIntensity:0.f];
  [self.view addSubview:_blurredImageView];
  
  _increaseBlur = YES;
}

////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [self updateBlur];
}

////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Blur updating
////////////////////////////////////////////////////////
- (void)updateBlur
{
  CGFloat blurIncrement = 0.01f;
  CGFloat newBlur = _blurredImageView.blurIntensity;
  
  if (newBlur >= 1.f)
    _increaseBlur = NO;
  else if (newBlur <= 0.f)
    _increaseBlur = YES;
  
  if (_increaseBlur)
    newBlur += blurIncrement;
  else
    newBlur -= blurIncrement;
  
  [_blurredImageView setBlurIntensity:newBlur];
  
  double delayInSeconds = 0.04f;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self updateBlur];
  });
}

////////////////////////////////////////////////////////
@end
