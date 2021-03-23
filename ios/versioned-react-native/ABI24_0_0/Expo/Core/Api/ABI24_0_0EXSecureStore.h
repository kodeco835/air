// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI24_0_0EXScopedBridgeModule.h"

@class ABI24_0_0EXSecureStore;

typedef NS_ENUM(NSInteger, ABI24_0_0EXSecureStoreAccessible) {
  ABI24_0_0EXSecureStoreAccessibleAfterFirstUnlock = 0,
  ABI24_0_0EXSecureStoreAccessibleAfterFirstUnlockThisDeviceOnly = 1,
  ABI24_0_0EXSecureStoreAccessibleAlways = 2,
  ABI24_0_0EXSecureStoreAccessibleWhenPasscodeSetThisDeviceOnly = 3,
  ABI24_0_0EXSecureStoreAccessibleAlwaysThisDeviceOnly = 4,
  ABI24_0_0EXSecureStoreAccessibleWhenUnlocked = 5,
  ABI24_0_0EXSecureStoreAccessibleWhenUnlockedThisDeviceOnly = 6
};

@interface ABI24_0_0EXSecureStore: ABI24_0_0EXScopedBridgeModule

@end
