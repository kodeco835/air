//
//  ABI23_0_0RNBranchEventEmitter.h
//  Pods
//
//  Created by Jimmy Dee on 4/6/17.
//
//  Based on https://gist.github.com/andybangs/c4651a3916ebde0df1c977b220bbec4b

#import <ReactABI23_0_0/ABI23_0_0RCTEventEmitter.h>
#import <ReactABI23_0_0/ABI23_0_0RCTBridge.h>

extern NSString * const ABI23_0_0RNBranchInitSessionSuccess;
extern NSString * const ABI23_0_0RNBranchInitSessionError;

@interface ABI23_0_0RNBranchEventEmitter : ABI23_0_0RCTEventEmitter<ABI23_0_0RCTBridgeModule>

+ (void)initSessionDidSucceedWithPayload:(NSDictionary<NSString *, id> *)payload;
+ (void)initSessionDidEncounterErrorWithPayload:(NSDictionary<NSString *, id> *)payload;

@end
