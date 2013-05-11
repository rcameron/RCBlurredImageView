# RCBlurredImageView

![demo](https://github.com/rcameron/RCBlurredImageView/blob/master/demo.gif?raw=true)

An iOS component that mimics the Yahoo Weather app's blurring effect

## Usage

Use just like UIImageView:

```objective-c
UIImage *image = [UIImage imageNamed:@"test.jpg"];
RCBlurredImageView *blurredImageView = [[RCBlurredImageView alloc] initWithImage:image];
[self.view addSubview:blurredImageView];
```

To change the blur intensity:

```objective-c
[blurredImageView setBlurIntensity:0.5f];
```
