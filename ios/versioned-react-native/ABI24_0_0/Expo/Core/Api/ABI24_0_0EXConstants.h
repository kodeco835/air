// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI24_0_0EXScopedBridgeModule.h"
#import "ABI24_0_0EXScopedModuleRegistry.h"

@interface ABI24_0_0EXConstants : ABI24_0_0EXScopedBridgeModule

@property (nonatomic, readonly) NSString *appOwnership;

@end

ABI24_0_0EX_DECLARE_SCOPED_MODULE_GETTER(ABI24_0_0EXConstants, constants)
