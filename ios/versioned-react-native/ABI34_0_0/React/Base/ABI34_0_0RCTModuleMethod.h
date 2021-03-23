/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <ReactABI34_0_0/ABI34_0_0RCTBridgeMethod.h>
#import <ReactABI34_0_0/ABI34_0_0RCTBridgeModule.h>
#import <ReactABI34_0_0/ABI34_0_0RCTNullability.h>

@class ABI34_0_0RCTBridge;

@interface ABI34_0_0RCTMethodArgument : NSObject

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, readonly) ABI34_0_0RCTNullability nullability;
@property (nonatomic, readonly) BOOL unused;

@end

@interface ABI34_0_0RCTModuleMethod : NSObject <ABI34_0_0RCTBridgeMethod>

@property (nonatomic, readonly) Class moduleClass;
@property (nonatomic, readonly) SEL selector;

- (instancetype)initWithExportedMethod:(const ABI34_0_0RCTMethodInfo *)exportMethod
                           moduleClass:(Class)moduleClass NS_DESIGNATED_INITIALIZER;

@end
