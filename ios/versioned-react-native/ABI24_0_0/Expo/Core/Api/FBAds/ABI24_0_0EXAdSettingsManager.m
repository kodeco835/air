#import "ABI24_0_0EXAdSettingsManager.h"
#import "ABI24_0_0EXUnversioned.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <ReactABI24_0_0/ABI24_0_0RCTUtils.h>
#import <ReactABI24_0_0/ABI24_0_0RCTConvert.h>

@implementation ABI24_0_0RCTConvert (ABI24_0_0EXNativeAdView)

ABI24_0_0RCT_ENUM_CONVERTER(FBAdLogLevel, (@{
  @"none": @(FBAdLogLevelNone),
  @"debug": @(FBAdLogLevelDebug),
  @"verbose": @(FBAdLogLevelVerbose),
  @"warning": @(FBAdLogLevelWarning),
  @"notification": @(FBAdLogLevelNotification),
  @"error": @(FBAdLogLevelError),
}), FBAdLogLevelLog, integerValue)

@end

@interface ABI24_0_0EXAdSettingsManager ()

@property (nonatomic) BOOL isChildDirected;
@property (nonatomic, strong) NSString *mediationService;
@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic) FBAdLogLevel logLevel;
@property (nonatomic, strong) NSMutableArray<NSString*> *testDevices;

@end

@implementation ABI24_0_0EXAdSettingsManager

@synthesize bridge = _bridge;

ABI24_0_0RCT_EXPORT_MODULE(CTKAdSettingsManager)

- (instancetype)init {
  if (self = [super init]) {
    _testDevices = [NSMutableArray new];
    _urlPrefix = @"";
    _mediationService = @"";
  }
  return self;
}

- (void)setBridge:(ABI24_0_0RCTBridge *)bridge
{
  _bridge = bridge;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:@"EXKernelBridgeDidForegroundNotification"
                                             object:self.bridge];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:@"EXKernelBridgeDidBackgroundNotification"
                                             object:self.bridge];
}

ABI24_0_0RCT_EXPORT_METHOD(addTestDevice:(NSString *)deviceHash)
{
  [FBAdSettings addTestDevice:deviceHash];
  [_testDevices addObject:deviceHash];
}

ABI24_0_0RCT_EXPORT_METHOD(clearTestDevices)
{
  [FBAdSettings clearTestDevices];
  [_testDevices removeAllObjects];
}

ABI24_0_0RCT_EXPORT_METHOD(setLogLevel:(FBAdLogLevel)logLevel)
{
  [FBAdSettings setLogLevel:logLevel];
  _logLevel = logLevel;
}

ABI24_0_0RCT_EXPORT_METHOD(setIsChildDirected:(BOOL)isDirected)
{
  [FBAdSettings setIsChildDirected:isDirected];
  _isChildDirected = isDirected;
}

ABI24_0_0RCT_EXPORT_METHOD(setMediationService:(NSString *)mediationService)
{
  [FBAdSettings setMediationService:mediationService];
  _mediationService = mediationService;
}

ABI24_0_0RCT_EXPORT_METHOD(setUrlPrefix:(NSString *)urlPrefix)
{
  [FBAdSettings setUrlPrefix:urlPrefix];
  _urlPrefix = urlPrefix;
}

- (void)bridgeDidForeground:(NSNotification *)notification
{
  [FBAdSettings setIsChildDirected:_isChildDirected];
  [FBAdSettings setMediationService:_mediationService];
  [FBAdSettings setUrlPrefix:_urlPrefix];
  [FBAdSettings setLogLevel:_logLevel];
  [FBAdSettings addTestDevices:_testDevices];
}

- (void)bridgeDidBackground:(NSNotification *)notification
{
  [FBAdSettings setIsChildDirected:NO];
  [FBAdSettings setMediationService:@""];
  [FBAdSettings setUrlPrefix:@""];
  [FBAdSettings setLogLevel:FBAdLogLevelLog];
  [FBAdSettings clearTestDevices];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)constantsToExport
{
  return @{ @"currentDeviceHash": [FBAdSettings testDeviceHash] };
}

@end
