/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ABI24_0_0RNSVGContainer.h"
#import "ABI24_0_0RNSVGCGFCRule.h"
#import "ABI24_0_0RNSVGSvgView.h"
#import "ABI24_0_0RNSVGPath.h"

@interface ABI24_0_0RNSVGGroup : ABI24_0_0RNSVGPath <ABI24_0_0RNSVGContainer>

- (void)renderPathTo:(CGContextRef)context;
- (void)renderGroupTo:(CGContextRef)context;

@end
