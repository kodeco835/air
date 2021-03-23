/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTSwitchManager.h"

#import "ABI26_0_0RCTBridge.h"
#import "ABI26_0_0RCTEventDispatcher.h"
#import "ABI26_0_0RCTSwitch.h"
#import "UIView+ReactABI26_0_0.h"

@implementation ABI26_0_0RCTSwitchManager

ABI26_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  ABI26_0_0RCTSwitch *switcher = [ABI26_0_0RCTSwitch new];
  [switcher addTarget:self
               action:@selector(onChange:)
     forControlEvents:UIControlEventValueChanged];
  return switcher;
}

- (void)onChange:(ABI26_0_0RCTSwitch *)sender
{
  if (sender.wasOn != sender.on) {
    if (sender.onChange) {
      sender.onChange(@{ @"value": @(sender.on) });
    }
    sender.wasOn = sender.on;
  }
}

ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(onTintColor, UIColor);
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor);
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(thumbTintColor, UIColor);
ABI26_0_0RCT_REMAP_VIEW_PROPERTY(value, on, BOOL);
ABI26_0_0RCT_EXPORT_VIEW_PROPERTY(onChange, ABI26_0_0RCTBubblingEventBlock);
ABI26_0_0RCT_CUSTOM_VIEW_PROPERTY(disabled, BOOL, ABI26_0_0RCTSwitch)
{
  if (json) {
    view.enabled = !([ABI26_0_0RCTConvert BOOL:json]);
  } else {
    view.enabled = defaultView.enabled;
  }
}

@end
