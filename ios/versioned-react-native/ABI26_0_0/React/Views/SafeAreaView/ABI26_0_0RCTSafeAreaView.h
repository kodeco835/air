/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <ReactABI26_0_0/ABI26_0_0RCTView.h>

NS_ASSUME_NONNULL_BEGIN

@class ABI26_0_0RCTBridge;

@interface ABI26_0_0RCTSafeAreaView : ABI26_0_0RCTView

- (instancetype)initWithBridge:(ABI26_0_0RCTBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
