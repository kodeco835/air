/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <ReactABI23_0_0/ABI23_0_0RCTBridgeModule.h>

@class ABI23_0_0RCTLayoutAnimation;

@interface ABI23_0_0RCTLayoutAnimationGroup : NSObject

@property (nonatomic, readonly) ABI23_0_0RCTLayoutAnimation *creatingLayoutAnimation;
@property (nonatomic, readonly) ABI23_0_0RCTLayoutAnimation *updatingLayoutAnimation;
@property (nonatomic, readonly) ABI23_0_0RCTLayoutAnimation *deletingLayoutAnimation;

@property (nonatomic, copy) ABI23_0_0RCTResponseSenderBlock callback;

- (instancetype)initWithCreatingLayoutAnimation:(ABI23_0_0RCTLayoutAnimation *)creatingLayoutAnimation
                        updatingLayoutAnimation:(ABI23_0_0RCTLayoutAnimation *)updatingLayoutAnimation
                        deletingLayoutAnimation:(ABI23_0_0RCTLayoutAnimation *)deletingLayoutAnimation
                                       callback:(ABI23_0_0RCTResponseSenderBlock)callback;

- (instancetype)initWithConfig:(NSDictionary *)config
                      callback:(ABI23_0_0RCTResponseSenderBlock)callback;

@end
