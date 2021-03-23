/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "ABI23_0_0RCTAssert.h"

#import "ABI23_0_0RCTBridge+Private.h"
#import "ABI23_0_0RCTBridge.h"
#import "ABI23_0_0RCTBridgeMethod.h"
#import "ABI23_0_0RCTConvert.h"
#import "ABI23_0_0RCTDisplayLink.h"
#import "ABI23_0_0RCTJSCExecutor.h"
#import "ABI23_0_0RCTJavaScriptLoader.h"
#import "ABI23_0_0RCTLog.h"
#import "ABI23_0_0RCTModuleData.h"
#import "ABI23_0_0RCTPerformanceLogger.h"
#import "ABI23_0_0RCTUtils.h"

#import <ReactABI23_0_0/ABI23_0_0RCTDevSettings.h>
#import <ReactABI23_0_0/ABI23_0_0RCTProfile.h>
#import <ReactABI23_0_0/ABI23_0_0RCTRedBox.h>

#if ABI23_0_0RCT_DEV && __has_include("ABI23_0_0RCTDevLoadingView.h")
#import "ABI23_0_0RCTDevLoadingView.h"
#endif

#define ABI23_0_0RCTAssertJSThread() \
  ABI23_0_0RCTAssert(![NSStringFromClass([self->_javaScriptExecutor class]) isEqualToString:@"ABI23_0_0RCTJSCExecutor"] || \
              [[[NSThread currentThread] name] isEqualToString:ABI23_0_0RCTJSCThreadName], \
            @"This method must be called on JS thread")

/**
 * Must be kept in sync with `MessageQueue.js`.
 */
typedef NS_ENUM(NSUInteger, ABI23_0_0RCTBridgeFields) {
  ABI23_0_0RCTBridgeFieldRequestModuleIDs = 0,
  ABI23_0_0RCTBridgeFieldMethodIDs,
  ABI23_0_0RCTBridgeFieldParams,
  ABI23_0_0RCTBridgeFieldCallID,
};

@implementation ABI23_0_0RCTBatchedBridge
{
  std::atomic_bool _wasBatchActive;
  NSMutableArray<dispatch_block_t> *_pendingCalls;
  NSDictionary<NSString *, ABI23_0_0RCTModuleData *> *_moduleDataByName;
  NSArray<ABI23_0_0RCTModuleData *> *_moduleDataByID;
  NSArray<Class> *_moduleClassesByID;
  NSUInteger _modulesInitializedOnMainQueue;
  ABI23_0_0RCTDisplayLink *_displayLink;
}

@synthesize flowID = _flowID;
@synthesize flowIDMap = _flowIDMap;
@synthesize flowIDMapLock = _flowIDMapLock;
@synthesize loading = _loading;
@synthesize valid = _valid;
@synthesize performanceLogger = _performanceLogger;
@synthesize bridgeDescription = _bridgeDescription;

- (instancetype)initWithParentBridge:(ABI23_0_0RCTBridge *)bridge
{
  ABI23_0_0RCTAssertParam(bridge);

  if (self = [super initWithDelegate:bridge.delegate
                           bundleURL:bridge.bundleURL
                      moduleProvider:bridge.moduleProvider
                       launchOptions:bridge.launchOptions]) {
    _parentBridge = bridge;
    _performanceLogger = [bridge performanceLogger];

    ABI23_0_0RCTLogInfo(@"Initializing %@ (parent: %@, executor: %@)", self, bridge, [self executorClass]);

    /**
     * Set Initial State
     */
    _valid = YES;
    _loading = YES;
    _pendingCalls = [NSMutableArray new];
    _displayLink = [ABI23_0_0RCTDisplayLink new];

    [ABI23_0_0RCTBridge setCurrentBridge:self];
  }
  return self;
}

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithDelegate:(__unused id<ABI23_0_0RCTBridgeDelegate>)delegate
                                           bundleURL:(__unused NSURL *)bundleURL
                                      moduleProvider:(__unused ABI23_0_0RCTBridgeModuleListProvider)block
                                       launchOptions:(__unused NSDictionary *)launchOptions)

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithBundleURL:(__unused NSURL *)bundleURL
                                       moduleProvider:(__unused ABI23_0_0RCTBridgeModuleListProvider)block
                                        launchOptions:(__unused NSDictionary *)launchOptions)

- (void)start
{
  [[NSNotificationCenter defaultCenter]
    postNotificationName:ABI23_0_0RCTJavaScriptWillStartLoadingNotification
    object:_parentBridge userInfo:@{@"bridge": self}];

  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI23_0_0RCTBatchedBridge setUp]", nil);

  dispatch_queue_t bridgeQueue = dispatch_queue_create("com.facebook.ReactABI23_0_0.ABI23_0_0RCTBridgeQueue", DISPATCH_QUEUE_CONCURRENT);

  dispatch_group_t initModulesAndLoadSource = dispatch_group_create();

  // Asynchronously load source code
  dispatch_group_enter(initModulesAndLoadSource);
  __weak ABI23_0_0RCTBatchedBridge *weakSelf = self;
  __block NSData *sourceCode;
  [self loadSource:^(NSError *error, ABI23_0_0RCTSource *source) {
    if (error) {
      ABI23_0_0RCTLogWarn(@"Failed to load source: %@", error);
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf stopLoadingWithError:error];
      });
    }

    sourceCode = source.data;
    dispatch_group_leave(initModulesAndLoadSource);
  } onProgress:^(ABI23_0_0RCTLoadingProgress *progressData) {
#if ABI23_0_0RCT_DEV && __has_include("ABI23_0_0RCTDevLoadingView.h")
    ABI23_0_0RCTDevLoadingView *loadingView = [weakSelf moduleForClass:[ABI23_0_0RCTDevLoadingView class]];
    [loadingView updateProgress:progressData];
#endif
  }];

  // Synchronously initialize all native modules that cannot be loaded lazily
  [self initModulesWithDispatchGroup:initModulesAndLoadSource];

  ABI23_0_0RCTPerformanceLogger *performanceLogger = self->_performanceLogger;
  __block NSString *config;
  dispatch_group_enter(initModulesAndLoadSource);
  dispatch_async(bridgeQueue, ^{
    dispatch_group_t setupJSExecutorAndModuleConfig = dispatch_group_create();

    // Asynchronously initialize the JS executor
    dispatch_group_async(setupJSExecutorAndModuleConfig, bridgeQueue, ^{
      [performanceLogger markStartForTag:ABI23_0_0RCTPLJSCExecutorSetup];
      [weakSelf setUpExecutor];
      [performanceLogger markStopForTag:ABI23_0_0RCTPLJSCExecutorSetup];
    });

    // Asynchronously gather the module config
    dispatch_group_async(setupJSExecutorAndModuleConfig, bridgeQueue, ^{
      if (weakSelf.valid) {
        ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI23_0_0RCTBatchedBridge moduleConfig", nil);
        [performanceLogger markStartForTag:ABI23_0_0RCTPLNativeModulePrepareConfig];
        config = [weakSelf moduleConfig];
        [performanceLogger markStopForTag:ABI23_0_0RCTPLNativeModulePrepareConfig];
        ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
      }
    });

    dispatch_group_notify(setupJSExecutorAndModuleConfig, bridgeQueue, ^{
      // We're not waiting for this to complete to leave dispatch group, since
      // injectJSONConfiguration and executeSourceCode will schedule operations
      // on the same queue anyway.
      [performanceLogger markStartForTag:ABI23_0_0RCTPLNativeModuleInjectConfig];
      [weakSelf injectJSONConfiguration:config onComplete:^(NSError *error) {
        [performanceLogger markStopForTag:ABI23_0_0RCTPLNativeModuleInjectConfig];
        if (error) {
          ABI23_0_0RCTLogWarn(@"Failed to inject config: %@", error);
          dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopLoadingWithError:error];
          });
        }
      }];
      dispatch_group_leave(initModulesAndLoadSource);
    });
  });

  dispatch_group_notify(initModulesAndLoadSource, bridgeQueue, ^{
    ABI23_0_0RCTBatchedBridge *strongSelf = weakSelf;
    if (sourceCode && strongSelf.loading) {
      [strongSelf executeSourceCode:sourceCode];
    }
  });

  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
}

- (void)loadSource:(ABI23_0_0RCTSourceLoadBlock)_onSourceLoad onProgress:(ABI23_0_0RCTSourceLoadProgressBlock)onProgress
{
  [_performanceLogger markStartForTag:ABI23_0_0RCTPLScriptDownload];

  ABI23_0_0RCTPerformanceLogger *performanceLogger = _performanceLogger;
  ABI23_0_0RCTSourceLoadBlock onSourceLoad = ^(NSError *error, ABI23_0_0RCTSource *source) {
    [performanceLogger markStopForTag:ABI23_0_0RCTPLScriptDownload];
    [performanceLogger setValue:source.length forTag:ABI23_0_0RCTPLBundleSize];
    _onSourceLoad(error, source);
  };

  if ([self.delegate respondsToSelector:@selector(loadSourceForBridge:onProgress:onComplete:)]) {
    [self.delegate loadSourceForBridge:_parentBridge onProgress:onProgress onComplete:onSourceLoad];
  } else if ([self.delegate respondsToSelector:@selector(loadSourceForBridge:withBlock:)]) {
    [self.delegate loadSourceForBridge:_parentBridge withBlock:onSourceLoad];
  } else if (!self.bundleURL) {
    NSError *error = ABI23_0_0RCTErrorWithMessage(@"No bundle URL present.\n\nMake sure you're running a packager " \
                                         "server or have included a .jsbundle file in your application bundle.");
    onSourceLoad(error, nil);
  } else {
    [ABI23_0_0RCTJavaScriptLoader loadBundleAtURL:self.bundleURL onProgress:onProgress onComplete:^(NSError *error, ABI23_0_0RCTSource *source) {
      if (error) {
        ABI23_0_0RCTLogError(@"Failed to load bundle(%@) with error:(%@ %@)", self.bundleURL, error.localizedDescription, error.localizedFailureReason);
      }
      onSourceLoad(error, source);
    }];
  }
}

- (NSArray<Class> *)moduleClasses
{
  if (ABI23_0_0RCT_DEBUG && _valid && _moduleClassesByID == nil) {
    ABI23_0_0RCTLogError(@"Bridge modules have not yet been initialized. You may be "
                "trying to access a module too early in the startup procedure.");
  }
  return _moduleClassesByID;
}

/**
 * Used by ABI23_0_0RCTUIManager
 */
- (ABI23_0_0RCTModuleData *)moduleDataForName:(NSString *)moduleName
{
  return _moduleDataByName[moduleName];
}

- (id)moduleForName:(NSString *)moduleName
{
  return _moduleDataByName[moduleName].instance;
}

- (BOOL)moduleIsInitialized:(Class)moduleClass
{
  return _moduleDataByName[ABI23_0_0RCTBridgeModuleNameForClass(moduleClass)].hasInstance;
}

- (NSArray *)configForModuleName:(NSString *)moduleName
{
  ABI23_0_0RCTModuleData *moduleData = _moduleDataByName[moduleName];
  if (moduleData) {
#if ABI23_0_0RCT_DEV
    if ([self.delegate respondsToSelector:@selector(whitelistedModulesForBridge:)]) {
      NSArray *whitelisted = [self.delegate whitelistedModulesForBridge:self];
      ABI23_0_0RCTAssert(!whitelisted || [whitelisted containsObject:[moduleData moduleClass]],
                @"Required config for %@, which was not whitelisted", moduleName);
    }
#endif
  }
  return moduleData.config;
}

- (void)initModulesWithDispatchGroup:(dispatch_group_t)dispatchGroup
{
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI23_0_0RCTBatchedBridge initModules]", nil);
  [_performanceLogger markStartForTag:ABI23_0_0RCTPLNativeModuleInit];

  NSArray<id<ABI23_0_0RCTBridgeModule>> *extraModules = nil;
  if (self.delegate) {
    if ([self.delegate respondsToSelector:@selector(extraModulesForBridge:)]) {
      extraModules = [self.delegate extraModulesForBridge:_parentBridge];
    }
  } else if (self.moduleProvider) {
    extraModules = self.moduleProvider();
  }

#if ABI23_0_0RCT_DEBUG
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ABI23_0_0RCTVerifyAllModulesExported(extraModules);
  });
#endif

  NSMutableArray<Class> *moduleClassesByID = [NSMutableArray new];
  NSMutableArray<ABI23_0_0RCTModuleData *> *moduleDataByID = [NSMutableArray new];
  NSMutableDictionary<NSString *, ABI23_0_0RCTModuleData *> *moduleDataByName = [NSMutableDictionary new];

  // Set up moduleData for pre-initialized module instances
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"extraModules", nil);
  for (id<ABI23_0_0RCTBridgeModule> module in extraModules) {
    Class moduleClass = [module class];
    NSString *moduleName = ABI23_0_0RCTBridgeModuleNameForClass(moduleClass);

    if (ABI23_0_0RCT_DEBUG) {
      // Check for name collisions between preregistered modules
      ABI23_0_0RCTModuleData *moduleData = moduleDataByName[moduleName];
      if (moduleData) {
        ABI23_0_0RCTLogError(@"Attempted to register ABI23_0_0RCTBridgeModule class %@ for the "
                    "name '%@', but name was already registered by class %@",
                    moduleClass, moduleName, moduleData.moduleClass);
        continue;
      }
    }

    // Instantiate moduleData container
    ABI23_0_0RCTModuleData *moduleData = [[ABI23_0_0RCTModuleData alloc] initWithModuleInstance:module
                                                                       bridge:self];
    moduleDataByName[moduleName] = moduleData;
    [moduleClassesByID addObject:moduleClass];
    [moduleDataByID addObject:moduleData];

    // Set executor instance
    if (moduleClass == self.executorClass) {
      _javaScriptExecutor = (id<ABI23_0_0RCTJavaScriptExecutor>)module;
    }
  }
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");

  // The executor is a bridge module, but we want it to be instantiated before
  // any other module has access to the bridge, in case they need the JS thread.
  // TODO: once we have more fine-grained control of init (t11106126) we can
  // probably just replace this with [self moduleForClass:self.executorClass]
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"JavaScriptExecutor", nil);
  if (!_javaScriptExecutor) {
    id<ABI23_0_0RCTJavaScriptExecutor> executorModule = [self.executorClass new];
    ABI23_0_0RCTModuleData *moduleData = [[ABI23_0_0RCTModuleData alloc] initWithModuleInstance:executorModule
                                                                       bridge:self];
    moduleDataByName[moduleData.name] = moduleData;
    [moduleClassesByID addObject:self.executorClass];
    [moduleDataByID addObject:moduleData];

    // NOTE: _javaScriptExecutor is a weak reference
    _javaScriptExecutor = executorModule;
  }
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");

  // Set up moduleData for automatically-exported modules
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"ModuleData", nil);
  for (Class moduleClass in ABI23_0_0RCTGetModuleClasses()) {
    NSString *moduleName = ABI23_0_0RCTBridgeModuleNameForClass(moduleClass);

    // Check for module name collisions
    ABI23_0_0RCTModuleData *moduleData = moduleDataByName[moduleName];
    if (moduleData) {
      if (moduleData.hasInstance) {
        // Existing module was preregistered, so it takes precedence
        continue;
      } else if ([moduleClass new] == nil) {
        // The new module returned nil from init, so use the old module
        continue;
      } else if ([moduleData.moduleClass new] != nil) {
        // Both modules were non-nil, so it's unclear which should take precedence
        ABI23_0_0RCTLogError(@"Attempted to register ABI23_0_0RCTBridgeModule class %@ for the "
                    "name '%@', but name was already registered by class %@",
                    moduleClass, moduleName, moduleData.moduleClass);
      }
    }

    // Instantiate moduleData (TODO: can we defer this until config generation?)
    moduleData = [[ABI23_0_0RCTModuleData alloc] initWithModuleClass:moduleClass
                                                     bridge:self];
    moduleDataByName[moduleName] = moduleData;
    [moduleClassesByID addObject:moduleClass];
    [moduleDataByID addObject:moduleData];
  }

  // Store modules
  _moduleDataByID = [moduleDataByID copy];
  _moduleDataByName = [moduleDataByName copy];
  _moduleClassesByID = [moduleClassesByID copy];
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");

  // Synchronously set up the pre-initialized modules
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"extraModules", nil);
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    if (moduleData.hasInstance &&
        (!moduleData.requiresMainQueueSetup || ABI23_0_0RCTIsMainQueue())) {
      // Modules that were pre-initialized should ideally be set up before
      // bridge init has finished, otherwise the caller may try to access the
      // module directly rather than via `[bridge moduleForClass:]`, which won't
      // trigger the lazy initialization process. If the module cannot safely be
      // set up on the current thread, it will instead be async dispatched
      // to the main thread to be set up in the loop below.
      (void)[moduleData instance];
    }
  }
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");

  // From this point on, ABI23_0_0RCTDidInitializeModuleNotification notifications will
  // be sent the first time a module is accessed.
  _moduleSetupComplete = YES;

  [self prepareModulesWithDispatchGroup:dispatchGroup];

  [_performanceLogger markStopForTag:ABI23_0_0RCTPLNativeModuleInit];
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
}

- (void)prepareModulesWithDispatchGroup:(dispatch_group_t)dispatchGroup
{
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI23_0_0RCTBatchedBridge prepareModulesWithDispatch]", nil);

  NSArray<Class> *whitelistedModules = nil;
  if ([self.delegate respondsToSelector:@selector(whitelistedModulesForBridge:)]) {
    whitelistedModules = [self.delegate whitelistedModulesForBridge:self];
  }

  BOOL initializeImmediately = NO;
  if (dispatchGroup == NULL) {
    // If no dispatchGroup is passed in, we must prepare everything immediately.
    // We better be on the right thread too.
    ABI23_0_0RCTAssertMainQueue();
    initializeImmediately = YES;
  } else if ([self.delegate respondsToSelector:@selector(shouldBridgeInitializeNativeModulesSynchronously:)]) {
    initializeImmediately = [self.delegate shouldBridgeInitializeNativeModulesSynchronously:self];
  }

  // Set up modules that require main thread init or constants export
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    if (whitelistedModules && ![whitelistedModules containsObject:[moduleData moduleClass]]) {
      continue;
    }

    if (moduleData.requiresMainQueueSetup || moduleData.hasConstantsToExport) {
      // Modules that need to be set up on the main thread cannot be initialized
      // lazily when required without doing a dispatch_sync to the main thread,
      // which can result in deadlock. To avoid this, we initialize all of these
      // modules on the main thread in parallel with loading the JS code, so
      // they will already be available before they are ever required.
      dispatch_block_t block = ^{
        if (self.valid) {
          [self->_performanceLogger appendStartForTag:ABI23_0_0RCTPLNativeModuleMainThread];
          (void)[moduleData instance];
          [moduleData gatherConstants];
          [self->_performanceLogger appendStopForTag:ABI23_0_0RCTPLNativeModuleMainThread];
        }
      };

      if (initializeImmediately && ABI23_0_0RCTIsMainQueue()) {
        block();
      } else {
        // We've already checked that dispatchGroup is non-null, but this satisifies the
        // Xcode analyzer
        if (dispatchGroup) {
          dispatch_group_async(dispatchGroup, dispatch_get_main_queue(), block);
        }
      }
      _modulesInitializedOnMainQueue++;
    }
  }

  [_performanceLogger setValue:_modulesInitializedOnMainQueue forTag:ABI23_0_0RCTPLNativeModuleMainThreadUsesCount];
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
}

- (void)whitelistedModulesDidChange
{
  ABI23_0_0RCTAssertMainQueue();
  [self prepareModulesWithDispatchGroup:NULL];
}

- (void)setUpExecutor
{
  [_javaScriptExecutor setUp];
}

- (void)registerModuleForFrameUpdates:(id<ABI23_0_0RCTBridgeModule>)module
                       withModuleData:(ABI23_0_0RCTModuleData *)moduleData
{
  [_displayLink registerModuleForFrameUpdates:module withModuleData:moduleData];
}

- (NSString *)moduleConfig
{
  NSMutableArray<NSArray *> *config = [NSMutableArray new];
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    if (self.executorClass == [ABI23_0_0RCTJSCExecutor class]) {
      [config addObject:@[moduleData.name]];
    } else {
      [config addObject:ABI23_0_0RCTNullIfNil(moduleData.config)];
    }
  }

  return ABI23_0_0RCTJSONStringify(@{
    @"remoteModuleConfig": config,
  }, NULL);
}

- (void)injectJSONConfiguration:(NSString *)configJSON
                     onComplete:(void (^)(NSError *))onComplete
{
  if (!_valid) {
    return;
  }

  [_javaScriptExecutor injectJSONText:configJSON
                  asGlobalObjectNamed:@"__fbBatchedBridgeConfig"
                             callback:onComplete];
}

- (void)executeSourceCode:(NSData *)sourceCode
{
  if (!_valid || !_javaScriptExecutor) {
    return;
  }

  [self enqueueApplicationScript:sourceCode url:self.bundleURL onComplete:^(NSError *loadError) {
    if (!self->_valid) {
      return;
    }

    if (loadError) {
      ABI23_0_0RCTLogWarn(@"Failed to execute source code: %@ %@", [loadError localizedDescription], [loadError localizedFailureReason]);
      dispatch_async(dispatch_get_main_queue(), ^{
        [self stopLoadingWithError:loadError];
      });
      return;
    }

    // Register the display link to start sending js calls after everything is setup
    NSRunLoop *targetRunLoop = [self->_javaScriptExecutor isKindOfClass:[ABI23_0_0RCTJSCExecutor class]] ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];
    [self->_displayLink addToRunLoop:targetRunLoop];

    // Log metrics about native requires during the bridge startup.
    uint64_t nativeRequiresCount = [self->_performanceLogger valueForTag:ABI23_0_0RCTPLRAMNativeRequiresCount];
    [self->_performanceLogger setValue:nativeRequiresCount forTag:ABI23_0_0RCTPLRAMStartupNativeRequiresCount];
    uint64_t nativeRequires = [self->_performanceLogger valueForTag:ABI23_0_0RCTPLRAMNativeRequires];
    [self->_performanceLogger setValue:nativeRequires forTag:ABI23_0_0RCTPLRAMStartupNativeRequires];

    [self->_performanceLogger markStopForTag:ABI23_0_0RCTPLBridgeStartup];

    // Perform the notification on the main thread, so we can't run into
    // timing issues with ABI23_0_0RCTRootView
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter]
       postNotificationName:ABI23_0_0RCTJavaScriptDidLoadNotification
       object:self->_parentBridge userInfo:@{@"bridge": self}];

#if ABI23_0_0RCT_DEV
      ABI23_0_0RCTLogWarn(@"ABI23_0_0RCTBatchedBridge is deprecated and will be removed in a future ReactABI23_0_0 Native release. "
        "See https://fb.me/ReactABI23_0_0-cxx-bridge for upgrade instructions.");
#endif
    });

    [self _flushPendingCalls];
  }];

#if ABI23_0_0RCT_DEV
  if (_parentBridge.devSettings.isHotLoadingEnabled) {
    NSString *path = [self.bundleURL.path substringFromIndex:1]; // strip initial slash
    NSString *host = self.bundleURL.host;
    NSNumber *port = self.bundleURL.port;
    [self enqueueJSCall:@"HMRClient"
                 method:@"enable"
                   args:@[@"ios", path, host, ABI23_0_0RCTNullIfNil(port)]
             completion:NULL];
  }
#endif
}

- (void)_flushPendingCalls
{
  ABI23_0_0RCTAssertJSThread();

  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"Processing pendingCalls", @{ @"count": @(_pendingCalls.count) });
  _loading = NO;
  NSArray *pendingCalls = _pendingCalls;
  _pendingCalls = nil;
  for (dispatch_block_t call in pendingCalls) {
    call();
  }
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
}

- (void)stopLoadingWithError:(NSError *)error
{
  ABI23_0_0RCTAssertMainQueue();

  if (!_valid || !_loading) {
    return;
  }

  _loading = NO;
  [_javaScriptExecutor invalidate];

  [[NSNotificationCenter defaultCenter]
   postNotificationName:ABI23_0_0RCTJavaScriptDidFailToLoadNotification
   object:_parentBridge userInfo:@{@"bridge": self, @"error": error}];

  if ([error userInfo][ABI23_0_0RCTJSStackTraceKey]) {
    [self.redBox showErrorMessage:[error localizedDescription]
                        withStack:[error userInfo][ABI23_0_0RCTJSStackTraceKey]];
  }
  ABI23_0_0RCTFatal(error);
}

/**
 * Prevent super from calling setUp (that'd create another batchedBridge)
 */
- (void)setUp {}

- (void)reload
{
  [_parentBridge reload];
}

- (void)requestReload
{
  [_parentBridge requestReload];
}

- (Class)executorClass
{
  return _parentBridge.executorClass ?: [ABI23_0_0RCTJSCExecutor class];
}

- (void)setExecutorClass:(Class)executorClass
{
  ABI23_0_0RCTAssertMainQueue();

  _parentBridge.executorClass = executorClass;
}

- (NSURL *)bundleURL
{
  return _parentBridge.bundleURL;
}

- (void)setBundleURL:(NSURL *)bundleURL
{
  _parentBridge.bundleURL = bundleURL;
}

- (id<ABI23_0_0RCTBridgeDelegate>)delegate
{
  return _parentBridge.delegate;
}

- (BOOL)isLoading
{
  return _loading;
}

- (BOOL)isValid
{
  return _valid;
}

- (void)dispatchBlock:(dispatch_block_t)block
                queue:(dispatch_queue_t)queue
{
  if (queue == ABI23_0_0RCTJSThread) {
    ABI23_0_0RCTProfileBeginFlowEvent();
    ABI23_0_0RCTAssert(_javaScriptExecutor != nil, @"Need JS executor to schedule JS work");

    [_javaScriptExecutor executeBlockOnJavaScriptQueue:^{
      ABI23_0_0RCTProfileEndFlowEvent();

      ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"-[ABI23_0_0RCTBatchedBridge dispatchBlock", @{ @"loading": @(self.loading) });

      if (self.loading) {
        ABI23_0_0RCTAssert(self->_pendingCalls != nil, @"Can't add pending call, bridge is no longer loading");
        [self->_pendingCalls addObject:block];
      } else {
        block();
      }

      ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
    }];
  } else if (queue) {
    dispatch_async(queue, block);
  }
}

#pragma mark - ABI23_0_0RCTInvalidating

- (void)invalidate
{
  if (!_valid) {
    return;
  }

  ABI23_0_0RCTAssertMainQueue();
  ABI23_0_0RCTAssert(_javaScriptExecutor != nil, @"Can't complete invalidation without a JS executor");

  _loading = NO;
  _valid = NO;
  if ([ABI23_0_0RCTBridge currentBridge] == self) {
    [ABI23_0_0RCTBridge setCurrentBridge:nil];
  }

  // Invalidate modules
  dispatch_group_t group = dispatch_group_create();
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    // Be careful when grabbing an instance here, we don't want to instantiate
    // any modules just to invalidate them.
    id<ABI23_0_0RCTBridgeModule> instance = nil;
    if ([moduleData hasInstance]) {
      instance = moduleData.instance;
    }

    if (instance == _javaScriptExecutor) {
      continue;
    }

    if ([instance respondsToSelector:@selector(invalidate)]) {
      dispatch_group_enter(group);
      [self dispatchBlock:^{
        [(id<ABI23_0_0RCTInvalidating>)instance invalidate];
        dispatch_group_leave(group);
      } queue:moduleData.methodQueue];
    }
    [moduleData invalidate];
  }

  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    [self->_javaScriptExecutor executeBlockOnJavaScriptQueue:^{
      [self->_displayLink invalidate];
      self->_displayLink = nil;

      [self->_javaScriptExecutor invalidate];
      self->_javaScriptExecutor = nil;

      if (ABI23_0_0RCTProfileIsProfiling()) {
        ABI23_0_0RCTProfileUnhookModules(self);
      }

      self->_moduleDataByName = nil;
      self->_moduleDataByID = nil;
      self->_moduleClassesByID = nil;
      self->_pendingCalls = nil;

      if (self->_flowIDMap != NULL) {
        CFRelease(self->_flowIDMap);
      }
    }];
  });
}

- (void)logMessage:(NSString *)message level:(NSString *)level
{
  if (ABI23_0_0RCT_DEBUG && [_javaScriptExecutor isValid]) {
    [self enqueueJSCall:@"ABI23_0_0RCTLog"
                 method:@"logIfNoNativeHook"
                   args:@[level, message]
             completion:NULL];
  }
}

#pragma mark - ABI23_0_0RCTBridge methods

/**
 * Public. Can be invoked from any thread.
 */
- (void)enqueueJSCall:(NSString *)module method:(NSString *)method args:(NSArray *)args completion:(dispatch_block_t)completion
{
 module = ABI23_0_0EX_REMOVE_VERSION(module);
 /**
   * AnyThread
   */
  if (!_valid) {
    return;
  }

  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(ABI23_0_0RCTProfileTagAlways, @"-[ABI23_0_0RCTBatchedBridge enqueueJSCall:]", nil);
  __weak __typeof(self) weakSelf = self;
  [self dispatchBlock:^{
    [weakSelf _actuallyInvokeAndProcessModule:module method:method arguments:args ?: @[]];
    if (completion) {
      completion();
    }
  } queue:ABI23_0_0RCTJSThread];
  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"");
}

/**
 * Called by ABI23_0_0RCTModuleMethod from any thread.
 */
- (void)enqueueCallback:(NSNumber *)cbID args:(NSArray *)args
{
  /**
   * AnyThread
   */
  if (!_valid) {
    return;
  }

  __weak __typeof(self) weakSelf = self;
  [self dispatchBlock:^{
    [weakSelf _actuallyInvokeCallback:cbID arguments:args];
  } queue:ABI23_0_0RCTJSThread];
}

/**
 * JS thread only
 */
- (JSValue *)callFunctionOnModule:(NSString *)module
                           method:(NSString *)method
                        arguments:(NSArray *)arguments
                            error:(NSError **)error
{
  ABI23_0_0RCTJSCExecutor *jsExecutor = (ABI23_0_0RCTJSCExecutor *)_javaScriptExecutor;
  if (![jsExecutor isKindOfClass:[ABI23_0_0RCTJSCExecutor class]]) {
    ABI23_0_0RCTLogWarn(@"FBReactABI23_0_0BridgeJSExecutor is only supported when running in JSC");
    return nil;
  }

  __block JSValue *jsResult = nil;

  ABI23_0_0RCTAssertJSThread();
  ABI23_0_0RCT_PROFILE_BEGIN_EVENT(0, @"callFunctionOnModule", (@{ @"module": module, @"method": method }));
  [jsExecutor callFunctionOnModule:module
                            method:method
                         arguments:arguments ?: @[]
                   jsValueCallback:^(JSValue *result, NSError *jsError) {
    if (error) {
      *error = jsError;
    }

    JSValue *length = result[@"length"];
    ABI23_0_0RCTAssert([length isNumber] && [length toUInt32] == 2,
              @"Return value of a callFunction must be an array of size 2");

    jsResult = [result valueAtIndex:0];

    NSArray *nativeModuleCalls = [[result valueAtIndex:1] toArray];
    [self handleBuffer:nativeModuleCalls batchEnded:YES];
  }];

  ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"js_call");

  return jsResult;
}


/**
 * Private hack to support `setTimeout(fn, 0)`
 */
- (void)_immediatelyCallTimer:(NSNumber *)timer
{
  ABI23_0_0RCTAssertJSThread();
  [_javaScriptExecutor executeAsyncBlockOnJavaScriptQueue:^{
    [self _actuallyInvokeAndProcessModule:@"JSTimers"
                                   method:@"callTimers"
                                arguments:@[@[timer]]];
  }];
}

- (void)enqueueApplicationScript:(NSData *)script
                             url:(NSURL *)url
                      onComplete:(ABI23_0_0RCTJavaScriptCompleteBlock)onComplete
{
  ABI23_0_0RCTAssert(onComplete != nil, @"onComplete block passed in should be non-nil");

  ABI23_0_0RCTProfileBeginFlowEvent();
  [_javaScriptExecutor executeApplicationScript:script sourceURL:url onComplete:^(NSError *scriptLoadError) {
    ABI23_0_0RCTProfileEndFlowEvent();
    ABI23_0_0RCTAssertJSThread();

    if (scriptLoadError) {
      onComplete(scriptLoadError);
      return;
    }

    ABI23_0_0RCT_PROFILE_BEGIN_EVENT(ABI23_0_0RCTProfileTagAlways, @"FetchApplicationScriptCallbacks", nil);
    [self->_javaScriptExecutor flushedQueue:^(id json, NSError *error)
     {
       ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"js_call,init");
       [self handleBuffer:json batchEnded:YES];
       onComplete(error);
     }];
  }];
}

#pragma mark - Payload Generation

- (void)_actuallyInvokeAndProcessModule:(NSString *)module
                                 method:(NSString *)method
                              arguments:(NSArray *)args
{
  ABI23_0_0RCTAssertJSThread();

  __weak __typeof(self) weakSelf = self;
  [_javaScriptExecutor callFunctionOnModule:module
                                     method:method
                                  arguments:args
                                   callback:^(id json, NSError *error) {
                                     [weakSelf _processResponse:json error:error];
                                   }];
}

- (void)_actuallyInvokeCallback:(NSNumber *)cbID
                      arguments:(NSArray *)args
{
  ABI23_0_0RCTAssertJSThread();

  __weak __typeof(self) weakSelf = self;
  [_javaScriptExecutor invokeCallbackID:cbID
                              arguments:args
                               callback:^(id json, NSError *error) {
                                 [weakSelf _processResponse:json error:error];
                               }];
}

- (void)_processResponse:(id)json error:(NSError *)error
{
  if (error) {
    if ([error userInfo][ABI23_0_0RCTJSStackTraceKey]) {
      [self.redBox showErrorMessage:[error localizedDescription]
                          withStack:[error userInfo][ABI23_0_0RCTJSStackTraceKey]];
    }
    ABI23_0_0RCTFatal(error);
  }

  if (!_valid) {
    return;
  }
  [self handleBuffer:json batchEnded:YES];
}

#pragma mark - Payload Processing

- (void)handleBuffer:(id)buffer batchEnded:(BOOL)batchEnded
{
  ABI23_0_0RCTAssertJSThread();

  if (!self.valid) {
    return;
  }

  if (buffer != nil && buffer != (id)kCFNull) {
    _wasBatchActive = YES;
    [self handleBuffer:buffer];
    [self partialBatchDidFlush];
  }

  if (batchEnded) {
    if (_wasBatchActive) {
      [self batchDidComplete];
    }

    _wasBatchActive = NO;
  }
}

- (void)handleBuffer:(NSArray *)buffer
{
  NSArray *requestsArray = [ABI23_0_0RCTConvert NSArray:buffer];

  if (ABI23_0_0RCT_DEBUG && requestsArray.count <= ABI23_0_0RCTBridgeFieldParams) {
    ABI23_0_0RCTLogError(@"Buffer should contain at least %tu sub-arrays. Only found %tu",
                ABI23_0_0RCTBridgeFieldParams + 1, requestsArray.count);
    return;
  }

  NSArray<NSNumber *> *moduleIDs = [ABI23_0_0RCTConvert NSNumberArray:requestsArray[ABI23_0_0RCTBridgeFieldRequestModuleIDs]];
  NSArray<NSNumber *> *methodIDs = [ABI23_0_0RCTConvert NSNumberArray:requestsArray[ABI23_0_0RCTBridgeFieldMethodIDs]];
  NSArray<NSArray *> *paramsArrays = [ABI23_0_0RCTConvert NSArrayArray:requestsArray[ABI23_0_0RCTBridgeFieldParams]];

  int64_t callID = -1;

  if (requestsArray.count > 3) {
    callID = [requestsArray[ABI23_0_0RCTBridgeFieldCallID] longLongValue];
  }

  if (ABI23_0_0RCT_DEBUG && (moduleIDs.count != methodIDs.count || moduleIDs.count != paramsArrays.count)) {
    ABI23_0_0RCTLogError(@"Invalid data message - all must be length: %zd", moduleIDs.count);
    return;
  }

  NSMapTable *buckets = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                                  valueOptions:NSPointerFunctionsStrongMemory
                                                      capacity:_moduleDataByName.count];

  [moduleIDs enumerateObjectsUsingBlock:^(NSNumber *moduleID, NSUInteger i, __unused BOOL *stop) {
    ABI23_0_0RCTModuleData *moduleData = self->_moduleDataByID[moduleID.integerValue];
    dispatch_queue_t queue = moduleData.methodQueue;
    NSMutableOrderedSet<NSNumber *> *set = [buckets objectForKey:queue];
    if (!set) {
      set = [NSMutableOrderedSet new];
      [buckets setObject:set forKey:queue];
    }
    [set addObject:@(i)];
  }];

  for (dispatch_queue_t queue in buckets) {
    ABI23_0_0RCTProfileBeginFlowEvent();

    dispatch_block_t block = ^{
      ABI23_0_0RCTProfileEndFlowEvent();

      NSOrderedSet *calls = [buckets objectForKey:queue];
      ABI23_0_0RCT_PROFILE_BEGIN_EVENT(ABI23_0_0RCTProfileTagAlways, @"-[ABI23_0_0RCTBatchedBridge handleBuffer:]", (@{
        @"calls": @(calls.count),
      }));

      @autoreleasepool {
        for (NSNumber *indexObj in calls) {
          NSUInteger index = indexObj.unsignedIntegerValue;
#if ABI23_0_0RCT_PROFILE
          if (ABI23_0_0RCT_DEV && callID != -1 && self->_flowIDMap != NULL && ABI23_0_0RCTProfileIsProfiling()) {
            [self.flowIDMapLock lock];
            NSUInteger newFlowID = (NSUInteger)CFDictionaryGetValue(self->_flowIDMap, (const void *)(self->_flowID + index));
            _ABI23_0_0RCTProfileEndFlowEvent(newFlowID);
            CFDictionaryRemoveValue(self->_flowIDMap, (const void *)(self->_flowID + index));
            [self.flowIDMapLock unlock];
          }
#endif
          [self callNativeModule:[moduleIDs[index] integerValue]
                          method:[methodIDs[index] integerValue]
                          params:paramsArrays[index]];
        }
      }

      ABI23_0_0RCT_PROFILE_END_EVENT(ABI23_0_0RCTProfileTagAlways, @"objc_call,dispatch_async");
    };

    [self dispatchBlock:block queue:queue];
  }

  _flowID = callID;
}

- (void)partialBatchDidFlush
{
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    if (moduleData.hasInstance && moduleData.implementsPartialBatchDidFlush) {
      [self dispatchBlock:^{
        [moduleData.instance partialBatchDidFlush];
      } queue:moduleData.methodQueue];
    }
  }
}

- (void)batchDidComplete
{
  // TODO: batchDidComplete is only used by ABI23_0_0RCTUIManager - can we eliminate this special case?
  for (ABI23_0_0RCTModuleData *moduleData in _moduleDataByID) {
    if (moduleData.hasInstance && moduleData.implementsBatchDidComplete) {
      [self dispatchBlock:^{
        [moduleData.instance batchDidComplete];
      } queue:moduleData.methodQueue];
    }
  }
}

- (id)callNativeModule:(NSUInteger)moduleID
                method:(NSUInteger)methodID
                params:(NSArray *)params
{
  if (!_valid) {
    return nil;
  }

  ABI23_0_0RCTModuleData *moduleData = _moduleDataByID[moduleID];
  if (ABI23_0_0RCT_DEBUG && !moduleData) {
    ABI23_0_0RCTLogError(@"No module found for id '%zd'", moduleID);
    return nil;
  }

  id<ABI23_0_0RCTBridgeMethod> method = moduleData.methods[methodID];
  if (ABI23_0_0RCT_DEBUG && !method) {
    ABI23_0_0RCTLogError(@"Unknown methodID: %zd for module: %zd (%@)", methodID, moduleID, moduleData.name);
    return nil;
  }

  @try {
    return [method invokeWithBridge:self module:moduleData.instance arguments:params];
  }
  @catch (NSException *exception) {
    // Pass on JS exceptions
    if ([exception.name hasPrefix:ABI23_0_0RCTFatalExceptionName]) {
      @throw exception;
    }

    NSString *message = [NSString stringWithFormat:
                         @"Exception '%@' was thrown while invoking %s on target %@ with params %@",
                         exception, method.JSMethodName, moduleData.name, params];
    ABI23_0_0RCTFatal(ABI23_0_0RCTErrorWithMessage(message));
    return nil;
  }
}

- (void)startProfiling
{
  ABI23_0_0RCTAssertMainQueue();

  [_javaScriptExecutor executeBlockOnJavaScriptQueue:^{
    ABI23_0_0RCTProfileInit(self);
  }];
}

- (void)stopProfiling:(void (^)(NSData *))callback
{
  ABI23_0_0RCTAssertMainQueue();

  [_javaScriptExecutor executeBlockOnJavaScriptQueue:^{
    ABI23_0_0RCTProfileEnd(self, ^(NSString *log) {
      NSData *logData = [log dataUsingEncoding:NSUTF8StringEncoding];
      callback(logData);
    });
  }];
}

- (BOOL)isBatchActive
{
  return _wasBatchActive;
}

#pragma mark - JavaScriptCore

- (JSGlobalContextRef)jsContextRef
{
  return [self.jsContext JSGlobalContextRef];
}

- (JSContext *)jsContext
{
  if ([_javaScriptExecutor isKindOfClass:[ABI23_0_0RCTJSCExecutor class]]) {
    return [(ABI23_0_0RCTJSCExecutor *)_javaScriptExecutor jsContext];
  } else {
    return nil;
  }
}

@end
