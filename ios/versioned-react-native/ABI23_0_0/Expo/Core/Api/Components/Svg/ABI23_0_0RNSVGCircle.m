/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI23_0_0RNSVGCircle.h"
#import <ReactABI23_0_0/ABI23_0_0RCTLog.h>

@implementation ABI23_0_0RNSVGCircle

- (void)setCx:(NSString *)cx
{
    if (cx == _cx) {
        return;
    }
    [self invalidate];
    _cx = cx;
}

- (void)setCy:(NSString *)cy
{
    if (cy == _cy) {
        return;
    }
    [self invalidate];
    _cy = cy;
}

- (void)setR:(NSString *)r
{
    if (r == _r) {
        return;
    }
    [self invalidate];
    _r = r;
}

- (CGPathRef)getPath:(CGContextRef)context
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat cx = [self relativeOnWidth:self.cx];
    CGFloat cy = [self relativeOnHeight:self.cy];
    CGFloat r;
    // radius percentage calculate formula:
    // radius = sqrt(pow((width*percent), 2) + pow((height*percent), 2)) / sqrt(2)
    
    if ([ABI23_0_0RNSVGPercentageConverter isPercentage:self.r]) {
        CGFloat radiusPercent = [ABI23_0_0RNSVGPercentageConverter percentageToFloat:self.r relative:1 offset:0];
        
        r = sqrt(
                 pow([self getContextWidth] * radiusPercent, 2) +
                 pow([self getContextHeight] * radiusPercent, 2)
                 ) / sqrt(2);
    } else {
        r = [self.r floatValue];
    }
    
    CGPathAddArc(path, nil, cx, cy, r, 0, 2*M_PI, NO);
    return (CGPathRef)CFAutorelease(path);
}

@end
