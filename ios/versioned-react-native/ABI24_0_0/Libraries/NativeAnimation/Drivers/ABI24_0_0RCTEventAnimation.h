/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI24_0_0/ABI24_0_0RCTEventDispatcher.h>

#import "ABI24_0_0RCTValueAnimatedNode.h"

@interface ABI24_0_0RCTEventAnimation : NSObject

@property (nonatomic, readonly, weak) ABI24_0_0RCTValueAnimatedNode *valueNode;

- (instancetype)initWithEventPath:(NSArray<NSString *> *)eventPath
                        valueNode:(ABI24_0_0RCTValueAnimatedNode *)valueNode;

- (void)updateWithEvent:(id<ABI24_0_0RCTEvent>)event;

@end
