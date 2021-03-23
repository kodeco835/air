/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI24_0_0RCTTestRunner.h"

#import <ReactABI24_0_0/ABI24_0_0RCTAssert.h>
#import <ReactABI24_0_0/ABI24_0_0RCTBridge+Private.h>
#import <ReactABI24_0_0/ABI24_0_0RCTDevSettings.h>
#import <ReactABI24_0_0/ABI24_0_0RCTLog.h>
#import <ReactABI24_0_0/ABI24_0_0RCTRootView.h>
#import <ReactABI24_0_0/ABI24_0_0RCTUtils.h>

#import "ABI24_0_0FBSnapshotTestController.h"
#import "ABI24_0_0RCTTestModule.h"

static const NSTimeInterval kTestTimeoutSeconds = 120;

@implementation ABI24_0_0RCTTestRunner
{
  FBSnapshotTestController *_testController;
  ABI24_0_0RCTBridgeModuleListProvider _moduleProvider;
  NSString *_appPath;
}

- (instancetype)initWithApp:(NSString *)app
         referenceDirectory:(NSString *)referenceDirectory
             moduleProvider:(ABI24_0_0RCTBridgeModuleListProvider)block
{
  ABI24_0_0RCTAssertParam(app);
  ABI24_0_0RCTAssertParam(referenceDirectory);

  if ((self = [super init])) {
    if (!referenceDirectory.length) {
      referenceDirectory = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"ReferenceImages"];
    }

    NSString *sanitizedAppName = [app stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    sanitizedAppName = [sanitizedAppName stringByReplacingOccurrencesOfString:@"\\" withString:@"-"];
    _testController = [[FBSnapshotTestController alloc] initWithTestName:sanitizedAppName];
    _testController.referenceImagesDirectory = referenceDirectory;
    _moduleProvider = [block copy];
    _appPath = app;
    [self updateScript];
  }
  return self;
}

ABI24_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (void)updateScript
{
  if (getenv("CI_USE_PACKAGER") || _useBundler) {
    _scriptURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8081/%@.bundle?platform=ios&dev=true", _appPath]];
  } else {
    _scriptURL = [[NSBundle bundleForClass:[ABI24_0_0RCTBridge class]] URLForResource:@"main" withExtension:@"jsbundle"];
  }
  ABI24_0_0RCTAssert(_scriptURL != nil, @"No scriptURL set");
}

- (void)setRecordMode:(BOOL)recordMode
{
  _testController.recordMode = recordMode;
}

- (BOOL)recordMode
{
  return _testController.recordMode;
}

- (void)setUseBundler:(BOOL)useBundler
{
  _useBundler = useBundler;
  [self updateScript];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
{
  [self runTest:test module:moduleName initialProps:nil configurationBlock:nil expectErrorBlock:nil];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI24_0_0RCTRootView *rootView))configurationBlock
{
  [self runTest:test module:moduleName initialProps:initialProps configurationBlock:configurationBlock expectErrorBlock:nil];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI24_0_0RCTRootView *rootView))configurationBlock
expectErrorRegex:(NSString *)errorRegex
{
  BOOL(^expectErrorBlock)(NSString *error)  = ^BOOL(NSString *error){
    return [error rangeOfString:errorRegex options:NSRegularExpressionSearch].location != NSNotFound;
  };

  [self runTest:test module:moduleName initialProps:initialProps configurationBlock:configurationBlock expectErrorBlock:expectErrorBlock];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI24_0_0RCTRootView *rootView))configurationBlock
expectErrorBlock:(BOOL(^)(NSString *error))expectErrorBlock
{
  __weak ABI24_0_0RCTBridge *batchedBridge;

  @autoreleasepool {
    __block NSString *error = nil;
    ABI24_0_0RCTLogFunction defaultLogFunction = ABI24_0_0RCTGetLogFunction();
    ABI24_0_0RCTSetLogFunction(^(ABI24_0_0RCTLogLevel level, ABI24_0_0RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
      defaultLogFunction(level, source, fileName, lineNumber, message);
      if (level >= ABI24_0_0RCTLogLevelError) {
        error = message;
      }
    });

    ABI24_0_0RCTBridge *bridge = [[ABI24_0_0RCTBridge alloc] initWithBundleURL:_scriptURL
                                              moduleProvider:_moduleProvider
                                               launchOptions:nil];
    [bridge.devSettings setIsDebuggingRemotely:_useJSDebugger];
    batchedBridge = [bridge batchedBridge];

    ABI24_0_0RCTRootView *rootView = [[ABI24_0_0RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:initialProps];
#if TARGET_OS_TV
    rootView.frame = CGRectMake(0, 0, 1920, 1080); // Standard screen size for tvOS
#else
    rootView.frame = CGRectMake(0, 0, 320, 2000); // Constant size for testing on multiple devices
#endif

    ABI24_0_0RCTTestModule *testModule = [rootView.bridge moduleForClass:[ABI24_0_0RCTTestModule class]];
    ABI24_0_0RCTAssert(_testController != nil, @"_testController should not be nil");
    testModule.controller = _testController;
    testModule.testSelector = test;
    testModule.testSuffix = _testSuffix;
    testModule.view = rootView;

    UIViewController *vc = ABI24_0_0RCTSharedApplication().delegate.window.rootViewController;
    vc.view = [UIView new];
    [vc.view addSubview:rootView]; // Add as subview so it doesn't get resized

    if (configurationBlock) {
      configurationBlock(rootView);
    }

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:kTestTimeoutSeconds];
    while (date.timeIntervalSinceNow > 0 && testModule.status == ABI24_0_0RCTTestStatusPending && error == nil) {
      [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
      [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    [rootView removeFromSuperview];

    ABI24_0_0RCTSetLogFunction(defaultLogFunction);

#if ABI24_0_0RCT_DEV
    NSArray<UIView *> *nonLayoutSubviews = [vc.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id subview, NSDictionary *bindings) {
      return ![NSStringFromClass([subview class]) isEqualToString:@"_UILayoutGuide"];
    }]];

    ABI24_0_0RCTAssert(nonLayoutSubviews.count == 0, @"There shouldn't be any other views: %@", nonLayoutSubviews);
#endif

    if (expectErrorBlock) {
      ABI24_0_0RCTAssert(expectErrorBlock(error), @"Expected an error but nothing matched.");
    } else {
      ABI24_0_0RCTAssert(error == nil, @"RedBox error: %@", error);
      ABI24_0_0RCTAssert(testModule.status != ABI24_0_0RCTTestStatusPending, @"Test didn't finish within %0.f seconds", kTestTimeoutSeconds);
      ABI24_0_0RCTAssert(testModule.status == ABI24_0_0RCTTestStatusPassed, @"Test failed");
    }

    [bridge invalidate];
  }

  // Wait for bridge to disappear before continuing to the next test
  NSDate *invalidateTimeout = [NSDate dateWithTimeIntervalSinceNow:30];
  while (invalidateTimeout.timeIntervalSinceNow > 0 && batchedBridge != nil) {
    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  ABI24_0_0RCTAssert(batchedBridge == nil, @"Bridge should be deallocated after the test");
}

@end
