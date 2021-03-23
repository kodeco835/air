#import "ABI23_0_0RNAdMobRewarded.h"

@implementation ABI23_0_0RNAdMobRewarded {
  NSString *_adUnitID;
  NSString *_testDeviceID;
  ABI23_0_0RCTResponseSenderBlock _requestAdCallback;
  ABI23_0_0RCTResponseSenderBlock _showAdCallback;
}

@synthesize bridge = _bridge;

+ (void)initialize
{
  NSLog(@"initialize");
  [GADRewardBasedVideoAd sharedInstance].delegate = self;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

ABI23_0_0RCT_EXPORT_MODULE();

#pragma mark exported methods

ABI23_0_0RCT_EXPORT_METHOD(setAdUnitID:(NSString *)adUnitID)
{
  _adUnitID = adUnitID;
}

ABI23_0_0RCT_EXPORT_METHOD(setTestDeviceID:(NSString *)testDeviceID)
{
  _testDeviceID = testDeviceID;
}

ABI23_0_0RCT_EXPORT_METHOD(requestAd:(ABI23_0_0RCTResponseSenderBlock)callback)
{
  _requestAdCallback = callback;
  [GADRewardBasedVideoAd sharedInstance].delegate = self;
  GADRequest *request = [GADRequest request];
  if(_testDeviceID) {
    if([_testDeviceID isEqualToString:@"EMULATOR"]) {
      request.testDevices = @[kGADSimulatorID];
    } else {
      request.testDevices = @[_testDeviceID];
    }
  }
  [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                         withAdUnitID:_adUnitID];
}

ABI23_0_0RCT_EXPORT_METHOD(showAd:(ABI23_0_0RCTResponseSenderBlock)callback)
{
  if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
    _showAdCallback = callback;
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
  }
  else {
    callback(@[@"Ad is not ready."]); // TODO: make proper error via ABI23_0_0RCTUtils.h
  }
}

ABI23_0_0RCT_EXPORT_METHOD(isReady:(ABI23_0_0RCTResponseSenderBlock)callback)
{
  callback(@[[NSNumber numberWithBool:[[GADRewardBasedVideoAd sharedInstance] isReady]]]);
}


#pragma mark delegate events

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoDidRewardUser" body:@{@"type": reward.type, @"amount": reward.amount}];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoDidLoad" body:nil];
  _requestAdCallback(@[[NSNull null]]);
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoDidOpen" body:nil];
  _showAdCallback(@[[NSNull null]]);
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoDidClose" body:nil];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoWillLeaveApplication" body:nil];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"rewardedVideoDidFailToLoad" body:@{@"name": [error description]}];
  _requestAdCallback(@[[error description]]);
}

@end
