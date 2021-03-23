/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import "ABI24_0_0RCTAnimatedNode.h"

@class ABI24_0_0RCTValueAnimatedNode;

@protocol ABI24_0_0RCTValueAnimatedNodeObserver <NSObject>

- (void)animatedNode:(ABI24_0_0RCTValueAnimatedNode *)node didUpdateValue:(CGFloat)value;

@end

@interface ABI24_0_0RCTValueAnimatedNode : ABI24_0_0RCTAnimatedNode

- (void)setOffset:(CGFloat)offset;
- (void)flattenOffset;
- (void)extractOffset;

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, weak) id<ABI24_0_0RCTValueAnimatedNodeObserver> valueObserver;

@end
