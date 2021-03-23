/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTAppState.h"

#import "ABI26_0_0RCTAssert.h"
#import "ABI26_0_0RCTBridge.h"
#import "ABI26_0_0RCTEventDispatcher.h"
#import "ABI26_0_0RCTUtils.h"

static NSString *ABI26_0_0RCTCurrentAppBackgroundState()
{
  static NSDictionary *states;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    states = @{
      @(UIApplicationStateActive): @"active",
      @(UIApplicationStateBackground): @"background"
    };
  });

  if (ABI26_0_0RCTRunningInAppExtension()) {
    return @"extension";
  }

  return states[@(ABI26_0_0RCTSharedApplication().applicationState)] ?: @"unknown";
}

@implementation ABI26_0_0RCTAppState
{
  NSString *_lastKnownState;
}

ABI26_0_0RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport
{
  return @{@"initialAppState": ABI26_0_0RCTCurrentAppBackgroundState()};
}

#pragma mark - Lifecycle

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"appStateDidChange", @"memoryWarning"];
}

- (void)startObserving
{
  for (NSString *name in @[UIApplicationDidBecomeActiveNotification,
                           UIApplicationDidEnterBackgroundNotification,
                           UIApplicationDidFinishLaunchingNotification,
                           UIApplicationWillResignActiveNotification,
                           UIApplicationWillEnterForegroundNotification]) {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppStateDidChange:)
                                                 name:name
                                               object:nil];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleMemoryWarning)
                                               name:UIApplicationDidReceiveMemoryWarningNotification
                                             object:nil];
}

- (void)stopObserving
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - App Notification Methods

- (void)handleMemoryWarning
{
  [self sendEventWithName:@"memoryWarning" body:nil];
}

- (void)handleAppStateDidChange:(NSNotification *)notification
{
  NSString *newState;

  if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
    newState = @"inactive";
  } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    newState = @"background";
  } else {
    newState = ABI26_0_0RCTCurrentAppBackgroundState();
  }

  if (![newState isEqualToString:_lastKnownState]) {
    _lastKnownState = newState;
    [self sendEventWithName:@"appStateDidChange"
                       body:@{@"app_state": _lastKnownState}];
  }
}

#pragma mark - Public API

/**
 * Get the current background/foreground state of the app
 */
ABI26_0_0RCT_EXPORT_METHOD(getCurrentAppState:(ABI26_0_0RCTResponseSenderBlock)callback
                  error:(__unused ABI26_0_0RCTResponseSenderBlock)error)
{
  callback(@[@{@"app_state": ABI26_0_0RCTCurrentAppBackgroundState()}]);
}

@end
