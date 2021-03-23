#import <ReactABI23_0_0/ABI23_0_0RCTComponent.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@class ABI23_0_0RCTEventDispatcher;

@interface ABI23_0_0RNDFPBannerView : UIView <GADBannerViewDelegate>

@property (nonatomic, copy) NSString *bannerSize;
@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, copy) NSString *testDeviceID;

@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onSizeChange;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdmobDispatchAppEvent;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdViewDidReceiveAd;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onDidFailToReceiveAdWithError;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdViewWillPresentScreen;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdViewWillDismissScreen;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdViewDidDismissScreen;
@property (nonatomic, copy) ABI23_0_0RCTBubblingEventBlock onAdViewWillLeaveApplication;

- (instancetype)initWithEventDispatcher:(ABI23_0_0RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;
- (GADAdSize)getAdSizeFromString:(NSString *)bannerSize;
- (void)loadBanner;

@end
