/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTSegmentedControlManager.h"

#import "ABI26_0_0RCTBridge.h"
#import "ABI26_0_0RCTConvert.h"
#import "ABI26_0_0RCTSegmentedControl.h"

@implementation ABI26_0_0RCTSegmentedControlManager

ABI26_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [ABI26_0_0RCTSegmentedControl new];
}

ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(values, NSArray<NSString *>)
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(selectedIndex, NSInteger)
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor)
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(momentary, BOOL)
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(enabled, BOOL)
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(onChange, ABI26_0_0RCTBubblingEventBlock)

@end
