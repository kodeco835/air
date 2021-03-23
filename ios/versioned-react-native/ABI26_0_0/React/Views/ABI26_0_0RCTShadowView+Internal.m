/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTShadowView+Layout.h"

@interface ABI26_0_0RCTShadowView ()
{
  __weak ABI26_0_0RCTRootShadowView *_rootView;
}

@end

@implementation ABI26_0_0RCTShadowView (Internal)

- (void)setRootView:(ABI26_0_0RCTRootShadowView *)rootView
{
  _rootView = rootView;
}

@end
