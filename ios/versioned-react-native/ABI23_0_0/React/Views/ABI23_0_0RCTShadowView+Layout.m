/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTShadowView+Layout.h"

#import <YogaABI23_0_0/ABI23_0_0Yoga.h>

@implementation ABI23_0_0RCTShadowView (Layout)

- (UIEdgeInsets)paddingAsInsets
{
  ABI23_0_0YGNodeRef yogaNode = self.yogaNode;
  return (UIEdgeInsets){
    ABI23_0_0YGNodeLayoutGetPadding(yogaNode, ABI23_0_0YGEdgeTop),
    ABI23_0_0YGNodeLayoutGetPadding(yogaNode, ABI23_0_0YGEdgeLeft),
    ABI23_0_0YGNodeLayoutGetPadding(yogaNode, ABI23_0_0YGEdgeBottom),
    ABI23_0_0YGNodeLayoutGetPadding(yogaNode, ABI23_0_0YGEdgeRight)
  };
}

- (UIEdgeInsets)borderAsInsets
{
  ABI23_0_0YGNodeRef yogaNode = self.yogaNode;
  return (UIEdgeInsets){
    ABI23_0_0YGNodeLayoutGetBorder(yogaNode, ABI23_0_0YGEdgeTop),
    ABI23_0_0YGNodeLayoutGetBorder(yogaNode, ABI23_0_0YGEdgeLeft),
    ABI23_0_0YGNodeLayoutGetBorder(yogaNode, ABI23_0_0YGEdgeBottom),
    ABI23_0_0YGNodeLayoutGetBorder(yogaNode, ABI23_0_0YGEdgeRight)
  };
}

- (UIEdgeInsets)compoundInsets
{
  UIEdgeInsets borderAsInsets = self.borderAsInsets;
  UIEdgeInsets paddingAsInsets = self.paddingAsInsets;

  return (UIEdgeInsets){
    borderAsInsets.top + paddingAsInsets.top,
    borderAsInsets.left + paddingAsInsets.left,
    borderAsInsets.bottom + paddingAsInsets.bottom,
    borderAsInsets.right + paddingAsInsets.right
  };
}

- (CGSize)availableSize
{
  return UIEdgeInsetsInsetRect((CGRect){CGPointZero, self.frame.size}, self.compoundInsets).size;
}

@end
