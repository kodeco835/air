/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class ABI26_0_0RCTNavItem;
@class ABI26_0_0RCTWrapperViewController;

@protocol ABI26_0_0RCTWrapperViewControllerNavigationListener <NSObject>

- (void)wrapperViewController:(ABI26_0_0RCTWrapperViewController *)wrapperViewController
didMoveToNavigationController:(UINavigationController *)navigationController;

@end

@interface ABI26_0_0RCTWrapperViewController : UIViewController

- (instancetype)initWithContentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNavItem:(ABI26_0_0RCTNavItem *)navItem;

@property (nonatomic, weak) id<ABI26_0_0RCTWrapperViewControllerNavigationListener> navigationListener;
@property (nonatomic, strong) ABI26_0_0RCTNavItem *navItem;

@end
