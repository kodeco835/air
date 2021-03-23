/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <ReactABI23_0_0/ABI23_0_0RCTComponent.h>
#import <ReactABI23_0_0/ABI23_0_0RCTConvert.h>

@interface ABI23_0_0RCTConvert (UITabBarSystemItem)

+ (UITabBarSystemItem)UITabBarSystemItem:(id)json;

@end

@interface ABI23_0_0RCTTabBarItem : UIView

@property (nonatomic, copy) id /* NSString or NSNumber */ badge;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, assign) UITabBarSystemItem systemIcon;
@property (nonatomic, assign) BOOL renderAsOriginal;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, readonly) UITabBarItem *barItem;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onPress;

#if TARGET_OS_TV
@property (nonatomic, assign) BOOL wasSelectedInJS;
#endif

@end
