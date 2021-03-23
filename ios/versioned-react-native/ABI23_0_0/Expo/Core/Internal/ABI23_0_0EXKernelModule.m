// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI23_0_0EXKernelModule.h"
#import "ABI23_0_0EXUnversioned.h"

#import <ReactABI23_0_0/ABI23_0_0RCTEventDispatcher.h>

@interface ABI23_0_0EXKernelModule ()

@property (nonatomic, assign) BOOL hasListeners;
@property (nonatomic, strong) NSMutableDictionary *eventSuccessBlocks;
@property (nonatomic, strong) NSMutableDictionary *eventFailureBlocks;
@property (nonatomic, strong) NSArray * _Nonnull sdkVersions;
@property (nonatomic, weak) id<ABI23_0_0EXKernelModuleDelegate> delegate;


@end

@implementation ABI23_0_0EXKernelModule

+ (NSString *)moduleName { return @"ExponentKernel"; }

- (instancetype)initWithExperienceId:(NSString *)experienceId kernelServiceDelegate:(id)kernelServiceInstance params:(NSDictionary *)params
{
  if (self = [super initWithExperienceId:experienceId kernelServiceDelegate:kernelServiceInstance params:params]) {
    _eventSuccessBlocks = [NSMutableDictionary dictionary];
    _eventFailureBlocks = [NSMutableDictionary dictionary];
    _sdkVersions = params[@"supportedSdkVersions"];
    _delegate = kernelServiceInstance;
  }
  return self;
}

- (NSDictionary *)constantsToExport
{
  return @{ @"sdkVersions": _sdkVersions };
}

#pragma mark - ABI23_0_0RCTEventEmitter methods

- (NSArray<NSString *> *)supportedEvents
{
  return @[];
}

/**
 *  Override this method to avoid the [self supportedEvents] validation
 */
- (void)sendEventWithName:(NSString *)eventName body:(id)body
{
  // Note that this could be a versioned bridge!
  [self.bridge enqueueJSCall:@"ABI23_0_0RCTDeviceEventEmitter.emit"
                        args:body ? @[eventName, body] : @[eventName]];
}

#pragma mark -

- (void)dispatchJSEvent:(NSString *)eventName body:(NSDictionary *)eventBody onSuccess:(void (^)(NSDictionary *))success onFailure:(void (^)(NSString *))failure
{
  NSString *qualifiedEventName = [NSString stringWithFormat:@"ExponentKernel.%@", eventName];
  NSMutableDictionary *qualifiedEventBody = (eventBody) ? [eventBody mutableCopy] : [NSMutableDictionary dictionary];

  if (success && failure) {
    NSString *eventId = [[NSUUID UUID] UUIDString];
    [_eventSuccessBlocks setObject:success forKey:eventId];
    [_eventFailureBlocks setObject:failure forKey:eventId];
    [qualifiedEventBody setObject:eventId forKey:@"eventId"];
  }

  [self sendEventWithName:qualifiedEventName body:qualifiedEventBody];
}

/**
 *  Duplicates Linking.openURL but does not validate that this is an exponent URL;
 *  in other words, we just take your word for it and never hand it off to iOS.
 *  Used by the home screen URL bar.
 */
ABI23_0_0RCT_EXPORT_METHOD(openURL:(NSURL *)URL
                  resolve:(ABI23_0_0RCTPromiseResolveBlock)resolve
                  reject:(__unused ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (URL) {
    [_delegate kernelModule:self didOpenUrl:URL.absoluteString];
    resolve(@YES);
  } else {
    NSError *err = [NSError errorWithDomain:@"EXKernelErrorDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"Cannot open a nil url" }];
    reject(@"E_INVALID_URL", err.localizedDescription, err);
  }
}

ABI23_0_0RCT_REMAP_METHOD(doesCurrentTaskEnableDevtools,
                 doesCurrentTaskEnableDevtoolsWithResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 reject:(ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (_delegate) {
    resolve(@([_delegate kernelModuleShouldEnableDevtools:self]));
  } else {
    // don't reject, just disable devtools
    resolve(@NO);
  }
}

ABI23_0_0RCT_REMAP_METHOD(shouldCurrentTaskAutoReload,
                 shouldCurrentTaskAutoReloadWithResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 reject:(ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (_delegate) {
    resolve(@([_delegate kernelModuleShouldAutoReloadCurrentTask:self]));
  } else {
    resolve(@NO);
  }
}

ABI23_0_0RCT_REMAP_METHOD(isLegacyMenuBehaviorEnabledAsync,
                 isLegacyMenuBehaviorEnabledWithResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (_delegate) {
    resolve(@([_delegate kernelModuleShouldEnableLegacyMenuBehavior:self]));
  } else {
    resolve(@(NO));
  }
}

ABI23_0_0RCT_EXPORT_METHOD(setIsLegacyMenuBehaviorEnabledAsync:(BOOL)isEnabled)
{
  if (_delegate) {
    [_delegate kernelModule:self didSelectEnableLegacyMenuBehavior:isEnabled];
  }
}

ABI23_0_0RCT_REMAP_METHOD(getDevMenuItemsToShow,
                 getDevMenuItemsToShowWithResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 reject:(ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (_delegate && [_delegate kernelModuleShouldEnableDevtools:self]) {
    resolve([_delegate devMenuItemsForKernelModule:self]);
  } else {
    // don't reject, just show no devtools
    resolve(@{});
  }
}

ABI23_0_0RCT_EXPORT_METHOD(selectDevMenuItemWithKey:(NSString *)key)
{
  if (_delegate) {
    [_delegate kernelModule:self didSelectDevMenuItemWithKey:key];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(addDevMenu)
{
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (weakSelf.delegate) {
      [weakSelf.delegate kernelModuleDidSelectKernelDevMenu:weakSelf];
    }
  });
}

ABI23_0_0RCT_REMAP_METHOD(routeDidForeground,
                 routeDidForegroundWithType:(NSUInteger)routeType
                 params:(NSDictionary *)params)
{
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (weakSelf.delegate) {
      [weakSelf.delegate kernelModule:weakSelf taskDidForegroundWithType:routeType params:params];
    }
  });
}

ABI23_0_0RCT_EXPORT_METHOD(onLoaded)
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"EXKernelJSIsLoadedNotification" object:self];
}

ABI23_0_0RCT_REMAP_METHOD(getManifestAsync,
                 getManifestWithUrl:(NSURL *)url
                 originalUrl:(NSURL *)originalUrl
                 resolve:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 reject:(ABI23_0_0RCTPromiseRejectBlock)reject)
{
  if (_delegate) {
    [_delegate kernelModule:self didRequestManifestWithUrl:url originalUrl:originalUrl success:^(NSString *manifestString) {
      resolve(manifestString);
    } failure:^(NSError *error) {
      reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    }];
  }
}

ABI23_0_0RCT_REMAP_METHOD(onEventSuccess,
                 eventId:(NSString *)eventId
                 body:(NSDictionary *)body)
{
  void (^success)(NSDictionary *) = [_eventSuccessBlocks objectForKey:eventId];
  if (success) {
    success(body);
    [_eventSuccessBlocks removeObjectForKey:eventId];
    [_eventFailureBlocks removeObjectForKey:eventId];
  }
}

ABI23_0_0RCT_REMAP_METHOD(onEventFailure,
                 eventId:(NSString *)eventId
                 message:(NSString *)message)
{
  void (^failure)(NSString *) = [_eventFailureBlocks objectForKey:eventId];
  if (failure) {
    failure(message);
    [_eventSuccessBlocks removeObjectForKey:eventId];
    [_eventFailureBlocks removeObjectForKey:eventId];
  }
}

@end
