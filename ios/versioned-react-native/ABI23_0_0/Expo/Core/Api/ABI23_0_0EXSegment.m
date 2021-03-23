// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI23_0_0EXSegment.h"

#import <SEGAnalytics.h>

@interface ABI23_0_0EXSegment ()

@property (nonatomic, strong) SEGAnalytics *instance;

@end

@implementation ABI23_0_0EXSegment

ABI23_0_0RCT_EXPORT_MODULE(ExponentSegment);

ABI23_0_0RCT_EXPORT_METHOD(initializeIOS:(NSString *)writeKey)
{
  SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:writeKey];
  _instance = [[SEGAnalytics alloc] initWithConfiguration:configuration];
}

ABI23_0_0RCT_EXPORT_METHOD(initializeAndroid:(NSString *)writeKey)
{
  // NO-OP. Need this here because Segment has different keys for iOS and Android.
}

ABI23_0_0RCT_EXPORT_METHOD(identify:(NSString *)userId)
{
  if (_instance) {
    [_instance identify:userId];
  }
}


ABI23_0_0RCT_EXPORT_METHOD(identifyWithTraits:(NSString *)userId withTraits:(NSDictionary *)traits)
{
  if (_instance) {
    [_instance identify:userId traits:traits];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(track:(NSString *)event)
{
  if (_instance) {
    [_instance track:event];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(trackWithProperties:(NSString *)event withProperties:(NSDictionary *)properties)
{
  if (_instance) {
    [_instance track:event properties:properties];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(screen:(NSString *)screenName)
{
  if (_instance) {
    [_instance screen:screenName];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(screenWithProperties:(NSString *)screenName withProperties:(NSDictionary *) properties)
{
  if (_instance) {
    [_instance screen:screenName properties:properties];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(reset)
{
  if (_instance) {
    [_instance reset];
  }
}

ABI23_0_0RCT_EXPORT_METHOD(flush)
{
  if (_instance) {
    [_instance flush];
  }
}

@end
