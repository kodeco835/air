// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI23_0_0EXLinearGradient.h"
#import <ReactABI23_0_0/ABI23_0_0RCTConvert.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation ABI23_0_0EXLinearGradient

+ (Class)layerClass
{
  return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
  return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colorStrings
{
  NSMutableArray *colors = [NSMutableArray arrayWithCapacity:colorStrings.count];
  for (NSString *colorString in colorStrings) {
    UIColor *convertedColor = [ABI23_0_0RCTConvert UIColor:colorString];
    if (convertedColor) {
      [colors addObject:(id)convertedColor.CGColor];
    }
  }
  self.gradientLayer.colors = colors;
}

- (void)setStart:(CGPoint)start
{
  self.gradientLayer.startPoint = start;
}

- (void)setEnd:(CGPoint)end
{
  self.gradientLayer.endPoint = end;
}

- (void)setLocations:(NSArray *)locations
{
  self.gradientLayer.locations = locations;
}

@end
