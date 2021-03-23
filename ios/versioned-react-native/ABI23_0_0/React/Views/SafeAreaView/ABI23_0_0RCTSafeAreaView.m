/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTSafeAreaView.h"

#import <ReactABI23_0_0/ABI23_0_0RCTBridge.h>
#import <ReactABI23_0_0/ABI23_0_0RCTUIManager.h>

#import "ABI23_0_0RCTSafeAreaViewLocalData.h"

@implementation ABI23_0_0RCTSafeAreaView {
  __weak ABI23_0_0RCTBridge *_bridge;
  UIEdgeInsets _currentSafeAreaInsets;
}

- (instancetype)initWithBridge:(ABI23_0_0RCTBridge *)bridge
{
  if (self = [super initWithFrame:CGRectZero]) {
    _bridge = bridge;
  }

  return self;
}

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)decoder)
ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000 /* __IPHONE_11_0 */

static BOOL UIEdgeInsetsEqualToEdgeInsetsWithThreshold(UIEdgeInsets insets1, UIEdgeInsets insets2, CGFloat threshold) {
  return
    ABS(insets1.left - insets2.left) <= threshold &&
    ABS(insets1.right - insets2.right) <= threshold &&
    ABS(insets1.top - insets2.top) <= threshold &&
    ABS(insets1.bottom - insets2.bottom) <= threshold;
}

- (void)safeAreaInsetsDidChange
{
  if (![self respondsToSelector:@selector(safeAreaInsets)]) {
    return;
  }

  UIEdgeInsets safeAreaInsets = self.safeAreaInsets;

  if (UIEdgeInsetsEqualToEdgeInsetsWithThreshold(safeAreaInsets, _currentSafeAreaInsets, 1.0 / ABI23_0_0RCTScreenScale())) {
    return;
  }

  _currentSafeAreaInsets = safeAreaInsets;

  ABI23_0_0RCTSafeAreaViewLocalData *localData =
    [[ABI23_0_0RCTSafeAreaViewLocalData alloc] initWithInsets:safeAreaInsets];
  [_bridge.uiManager setLocalData:localData forView:self];
}

#endif

@end
