/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTNavigatorManager.h"

#import "ABI23_0_0RCTBridge.h"
#import "ABI23_0_0RCTConvert.h"
#import "ABI23_0_0RCTNavigator.h"
#import "ABI23_0_0RCTUIManager.h"
#import "UIView+ReactABI23_0_0.h"

@implementation ABI23_0_0RCTNavigatorManager

ABI23_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[ABI23_0_0RCTNavigator alloc] initWithBridge:self.bridge];
}

ABI23_0_0RCT_EXPORT_VIEW_PROPERTY(requestedTopOfStack, NSInteger)
ABI23_0_0RCT_EXPORT_VIEW_PROPERTY(onNavigationProgress, ABI23_0_0RCTDirectEventBlock)
ABI23_0_0RCT_EXPORT_VIEW_PROPERTY(onNavigationComplete, ABI23_0_0RCTBubblingEventBlock)
ABI23_0_0RCT_EXPORT_VIEW_PROPERTY(interactivePopGestureEnabled, BOOL)

ABI23_0_0RCT_EXPORT_METHOD(requestSchedulingJavaScriptNavigation:(nonnull NSNumber *)ReactABI23_0_0Tag
                  callback:(ABI23_0_0RCTResponseSenderBlock)callback)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused ABI23_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI23_0_0RCTNavigator *> *viewRegistry){
    ABI23_0_0RCTNavigator *navigator = viewRegistry[ReactABI23_0_0Tag];
    if ([navigator isKindOfClass:[ABI23_0_0RCTNavigator class]]) {
      BOOL wasAcquired = [navigator requestSchedulingJavaScriptNavigation];
      callback(@[@(wasAcquired)]);
    } else {
      ABI23_0_0RCTLogError(@"Cannot set lock: %@ (tag #%@) is not an ABI23_0_0RCTNavigator", navigator, ReactABI23_0_0Tag);
    }
  }];
}

@end
