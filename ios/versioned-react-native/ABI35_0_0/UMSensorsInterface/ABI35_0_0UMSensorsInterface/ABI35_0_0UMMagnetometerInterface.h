// Copyright 2018-present 650 Industries. All rights reserved.

@protocol ABI35_0_0UMMagnetometerInterface

- (void)sensorModuleDidSubscribeForMagnetometerUpdates:(id)scopedSensorModule withHandler:(void (^)(NSDictionary *event))handlerBlock;
- (void)sensorModuleDidUnsubscribeForMagnetometerUpdates:(id)scopedSensorModule;
- (void)setMagnetometerUpdateInterval:(NSTimeInterval)intervalMs;
- (BOOL)isMagnetometerAvailable;

@end
