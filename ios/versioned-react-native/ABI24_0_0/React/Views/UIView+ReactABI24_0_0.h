/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <ReactABI24_0_0/ABI24_0_0RCTComponent.h>
#import <yogaABI24_0_0/ABI24_0_0YGEnums.h>

@class ABI24_0_0RCTShadowView;

@interface UIView (ReactABI24_0_0) <ABI24_0_0RCTComponent>

/**
 * ABI24_0_0RCTComponent interface.
 */
- (NSArray<UIView *> *)ReactABI24_0_0Subviews NS_REQUIRES_SUPER;
- (UIView *)ReactABI24_0_0Superview NS_REQUIRES_SUPER;
- (void)insertReactABI24_0_0Subview:(UIView *)subview atIndex:(NSInteger)atIndex NS_REQUIRES_SUPER;
- (void)removeReactABI24_0_0Subview:(UIView *)subview NS_REQUIRES_SUPER;

/**
 * The native id of the view, used to locate view from native codes
 */
@property (nonatomic, copy) NSString *nativeID;

/**
 * Layout direction of the view.
 * Internally backed to `semanticContentAttribute` property.
 * Defaults to `LeftToRight` in case of ambiguity.
 */
@property (nonatomic, assign) UIUserInterfaceLayoutDirection ReactABI24_0_0LayoutDirection;

/**
 * Yoga `display` style property. Can be `flex` or `none`.
 * Defaults to `flex`.
 * May be used to temporary hide the view in a very efficient way.
 */
@property (nonatomic, assign) ABI24_0_0YGDisplay ReactABI24_0_0Display;

/**
 * The z-index of the view.
 */
@property (nonatomic, assign) NSInteger ReactABI24_0_0ZIndex;

/**
 * Subviews sorted by z-index. Note that this method doesn't do any caching (yet)
 * and sorts all the views each call.
 */
- (NSArray<UIView *> *)ReactABI24_0_0ZIndexSortedSubviews;

/**
 * Updates the subviews array based on the ReactABI24_0_0Subviews. Default behavior is
 * to insert the sortedReactABI24_0_0Subviews into the UIView.
 */
- (void)didUpdateReactABI24_0_0Subviews;

/**
 * Used by the UIIManager to set the view frame.
 * May be overriden to disable animation, etc.
 */
- (void)ReactABI24_0_0SetFrame:(CGRect)frame;

/**
 * Used to improve performance when compositing views with translucent content.
 */
- (void)ReactABI24_0_0SetInheritedBackgroundColor:(UIColor *)inheritedBackgroundColor;

/**
 * This method finds and returns the containing view controller for the view.
 */
- (UIViewController *)ReactABI24_0_0ViewController;

/**
 * This method attaches the specified controller as a child of the
 * the owning view controller of this view. Returns NO if no view
 * controller is found (which may happen if the view is not currently
 * attached to the view hierarchy).
 */
- (void)ReactABI24_0_0AddControllerToClosestParent:(UIViewController *)controller;

/**
 * Focus manipulation.
 */
- (void)ReactABI24_0_0Focus;
- (void)ReactABI24_0_0FocusIfNeeded;
- (void)ReactABI24_0_0Blur;

/**
 * Useful properties for computing layout.
 */
@property (nonatomic, readonly) UIEdgeInsets ReactABI24_0_0BorderInsets;
@property (nonatomic, readonly) UIEdgeInsets ReactABI24_0_0PaddingInsets;
@property (nonatomic, readonly) UIEdgeInsets ReactABI24_0_0CompoundInsets;
@property (nonatomic, readonly) CGRect ReactABI24_0_0ContentFrame;

/**
 * The (sub)view which represents this view in terms of accessibility.
 * ViewManager will apply all accessibility properties directly to this view.
 * May be overriten in view subclass which needs to be accessiblitywise
 * transparent in favour of some subview.
 * Defaults to `self`.
 */
@property (nonatomic, readonly) UIView *ReactABI24_0_0AccessibilityElement;

#if ABI24_0_0RCT_DEV

/**
 Tools for debugging
 */

@property (nonatomic, strong, setter=_DEBUG_setReactABI24_0_0ShadowView:) ABI24_0_0RCTShadowView *_DEBUG_ReactABI24_0_0ShadowView;

#endif

@end
