/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTTVRemoteHandler.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "ABI23_0_0RCTAssert.h"
#import "ABI23_0_0RCTBridge.h"
#import "ABI23_0_0RCTEventDispatcher.h"
#import "ABI23_0_0RCTLog.h"
#import "ABI23_0_0RCTRootView.h"
#import "ABI23_0_0RCTTVNavigationEventEmitter.h"
#import "ABI23_0_0RCTUIManager.h"
#import "ABI23_0_0RCTUtils.h"
#import "ABI23_0_0RCTView.h"
#import "UIView+ReactABI23_0_0.h"

#if __has_include("ABI23_0_0RCTDevMenu.h")
#import "ABI23_0_0RCTDevMenu.h"
#endif

@implementation ABI23_0_0RCTTVRemoteHandler {
  NSMutableArray<UIGestureRecognizer *> *_tvRemoteGestureRecognizers;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _tvRemoteGestureRecognizers = [NSMutableArray array];

    // Recognizers for Apple TV remote buttons

    // Play/Pause
    [self addTapGestureRecognizerWithSelector:@selector(playPausePressed:)
                                    pressType:UIPressTypePlayPause];

    // Menu
    [self addTapGestureRecognizerWithSelector:@selector(menuPressed:)
                                    pressType:UIPressTypeMenu];

    // Select
    [self addTapGestureRecognizerWithSelector:@selector(selectPressed:)
                                    pressType:UIPressTypeSelect];

    // Up
    [self addTapGestureRecognizerWithSelector:@selector(swipedUp:)
                                    pressType:UIPressTypeUpArrow];

    // Down
    [self addTapGestureRecognizerWithSelector:@selector(swipedDown:)
                                    pressType:UIPressTypeDownArrow];

    // Left
    [self addTapGestureRecognizerWithSelector:@selector(swipedLeft:)
                                    pressType:UIPressTypeLeftArrow];

    // Right
    [self addTapGestureRecognizerWithSelector:@selector(swipedRight:)
                                    pressType:UIPressTypeRightArrow];

    // Recognizers for long button presses
    // We don't intercept long menu press -- that's used by the system to go to the home screen

    [self addLongPressGestureRecognizerWithSelector:@selector(longPlayPausePressed:)
                                          pressType:UIPressTypePlayPause];

    [self addLongPressGestureRecognizerWithSelector:@selector(longSelectPressed:)
                                          pressType:UIPressTypeSelect];

    // Recognizers for Apple TV remote trackpad swipes

    // Up
    [self addSwipeGestureRecognizerWithSelector:@selector(swipedUp:)
                                      direction:UISwipeGestureRecognizerDirectionUp];

    // Down
    [self addSwipeGestureRecognizerWithSelector:@selector(swipedDown:)
                                      direction:UISwipeGestureRecognizerDirectionDown];

    // Left
    [self addSwipeGestureRecognizerWithSelector:@selector(swipedLeft:)
                                      direction:UISwipeGestureRecognizerDirectionLeft];

    // Right
    [self addSwipeGestureRecognizerWithSelector:@selector(swipedRight:)
                                      direction:UISwipeGestureRecognizerDirectionRight];

  }

  return self;
}

- (void)playPausePressed:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"playPause" toView:r.view];
}

- (void)menuPressed:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"menu" toView:r.view];
}

- (void)selectPressed:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"select" toView:r.view];
}

- (void)longPlayPausePressed:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"longPlayPause" toView:r.view];

#if __has_include("ABI23_0_0RCTDevMenu.h") && ABI23_0_0RCT_DEV
  // If shake to show is enabled on device, use long play/pause event to show dev menu
  [[NSNotificationCenter defaultCenter] postNotificationName:ABI23_0_0RCTShowDevMenuNotification object:nil];
#endif
}

- (void)longSelectPressed:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"longSelect" toView:r.view];
}

- (void)swipedUp:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"up" toView:r.view];
}

- (void)swipedDown:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"down" toView:r.view];
}

- (void)swipedLeft:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"left" toView:r.view];
}

- (void)swipedRight:(UIGestureRecognizer *)r
{
  [self sendAppleTVEvent:@"right" toView:r.view];
}

#pragma mark -

- (void)addLongPressGestureRecognizerWithSelector:(nonnull SEL)selector pressType:(UIPressType)pressType
{
  UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector];
  recognizer.allowedPressTypes = @[@(pressType)];

  [_tvRemoteGestureRecognizers addObject:recognizer];
}

- (void)addTapGestureRecognizerWithSelector:(nonnull SEL)selector pressType:(UIPressType)pressType
{
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
  recognizer.allowedPressTypes = @[@(pressType)];

  [_tvRemoteGestureRecognizers addObject:recognizer];
}

- (void)addSwipeGestureRecognizerWithSelector:(nonnull SEL)selector direction:(UISwipeGestureRecognizerDirection)direction
{
  UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:selector];
  recognizer.direction = direction;

  [_tvRemoteGestureRecognizers addObject:recognizer];
}

- (void)sendAppleTVEvent:(NSString *)eventType toView:(__unused UIView *)v
{
  [[NSNotificationCenter defaultCenter] postNotificationName:ABI23_0_0RCTTVNavigationEventNotification
                                                      object:@{@"eventType":eventType}];
}


@end
