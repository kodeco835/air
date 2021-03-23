/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTModuloAnimatedNode.h"

@implementation ABI26_0_0RCTModuloAnimatedNode

- (void)performUpdate
{
  [super performUpdate];
  NSNumber *inputNode = self.config[@"input"];
  NSNumber *modulus = self.config[@"modulus"];
  ABI26_0_0RCTValueAnimatedNode *parent = (ABI26_0_0RCTValueAnimatedNode *)[self.parentNodes objectForKey:inputNode];
  self.value = fmodf(parent.value, modulus.floatValue);
}

@end
