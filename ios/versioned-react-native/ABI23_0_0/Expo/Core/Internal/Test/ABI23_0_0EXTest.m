// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI23_0_0EXTest.h"
#import "ABI23_0_0EXUnversioned.h"

NSNotificationName ABI23_0_0EXTestSuiteCompletedNotification = @"ABI23_0_0EXTestSuiteCompletedNotification";

@interface ABI23_0_0EXTest ()

@property (nonatomic, assign) ABI23_0_0EXTestEnvironment environment;

@end

@implementation ABI23_0_0EXTest

+ (NSString *)moduleName { return @"ExponentTest"; }

- (instancetype)initWithEnvironment:(ABI23_0_0EXTestEnvironment)environment
{
  if (self = [super init]) {
    _environment = environment;
  }
  return self;
}

ABI23_0_0RCT_EXPORT_METHOD(completed: (NSString *)jsonStringifiedResult)
{
  NSDictionary *failedResult = @{ @"failed": @(1) };
  
  __block NSError *jsonError;
  NSData *jsonData = [jsonStringifiedResult dataUsingEncoding:NSUTF8StringEncoding];
  id resultObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
  if (jsonError) {
    resultObj = failedResult;
  }

  [[NSNotificationCenter defaultCenter] postNotificationName:@"EXTestSuiteCompletedNotification"
                                                      object:nil
                                                    userInfo:resultObj];
}

ABI23_0_0RCT_REMAP_METHOD(action,
                 actionWithParams:(NSDictionary *)params
                 withResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(__unused ABI23_0_0RCTPromiseRejectBlock)reject)
{
  // stub on iOS
  resolve(@{});
}

ABI23_0_0RCT_REMAP_METHOD(shouldSkipTestsRequiringPermissionsAsync,
                 shouldSkipTestsRequiringPermissionsWithResolver:(ABI23_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(__unused ABI23_0_0RCTPromiseRejectBlock)reject)
{
  resolve(@(_environment == ABI23_0_0EXTestEnvironmentCI));
}

#pragma mark - util

+ (ABI23_0_0EXTestEnvironment)testEnvironmentFromString:(NSString *)testEnvironmentString
{
  if ([testEnvironmentString isEqualToString:@"local"]) {
    return ABI23_0_0EXTestEnvironmentLocal;
  } else if ([testEnvironmentString isEqualToString:@"ci"]) {
    return ABI23_0_0EXTestEnvironmentCI;
  }
  return ABI23_0_0EXTestEnvironmentNone;
}

@end
