//
//  ABI24_0_0AIRGMSMarker.h
//  AirMaps
//
//  Created by Gil Birman on 9/5/16.
//

#import <GoogleMaps/GoogleMaps.h>
#import <ReactABI24_0_0/UIView+ReactABI24_0_0.h>

@class ABI24_0_0AIRGoogleMapMarker;

@interface ABI24_0_0AIRGMSMarker : GMSMarker
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) ABI24_0_0AIRGoogleMapMarker *fakeMarker;
@property (nonatomic, copy) ABI24_0_0RCTBubblingEventBlock onPress;
@end


@protocol ABI24_0_0AIRGMSMarkerDelegate <NSObject>
@required
-(void)didTapMarker;
@end
