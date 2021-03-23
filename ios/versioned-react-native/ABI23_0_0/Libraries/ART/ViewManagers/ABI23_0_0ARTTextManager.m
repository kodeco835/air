/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0ARTTextManager.h"

#import "ABI23_0_0ARTText.h"
#import "ABI23_0_0RCTConvert+ART.h"

@implementation ABI23_0_0ARTTextManager

ABI23_0_0RCT_EXPORT_MODULE()

- (ABI23_0_0ARTRenderable *)node
{
  return [ABI23_0_0ARTText new];
}

ABI23_0_0RCT_EXPORT_VIEW_PROPERTY(alignment, CTTextAlignment)
ABI23_0_0RCT_REMAP_VIEW_PROPERTY(frame, textFrame, ABI23_0_0ARTTextFrame)

@end
