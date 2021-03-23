/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI26_0_0/ABI26_0_0RCTShadowView.h>
#import <YogaABI26_0_0/ABI26_0_0YGEnums.h>

@interface ABI26_0_0RCTRootShadowView : ABI26_0_0RCTShadowView

/**
 * Available size to layout all views.
 * Defaults to {INFINITY, INFINITY}
 */
@property (nonatomic, assign) CGSize availableSize;

/**
 * Layout direction (LTR or RTL) inherited from native environment and
 * is using as a base direction value in layout engine.
 * Defaults to value inferred from current locale.
 */
@property (nonatomic, assign) ABI26_0_0YGDirection baseDirection;

/**
 * Calculate all views whose frame needs updating after layout has been calculated.
 * Returns a set contains the shadowviews that need updating.
 */
- (NSSet<ABI26_0_0RCTShadowView *> *)collectViewsWithUpdatedFrames;

@end
