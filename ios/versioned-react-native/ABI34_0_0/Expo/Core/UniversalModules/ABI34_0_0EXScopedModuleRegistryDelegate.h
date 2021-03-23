// Copyright © 2018 650 Industries. All rights reserved.

#import <Foundation/Foundation.h>
#import <ABI34_0_0UMCore/ABI34_0_0UMModuleRegistry.h>
#import <ABI34_0_0UMCore/ABI34_0_0UMModuleRegistryDelegate.h>

@interface ABI34_0_0EXScopedModuleRegistryDelegate : NSObject <ABI34_0_0UMModuleRegistryDelegate>

- (instancetype)initWithParams:(NSDictionary *)params;

- (id<ABI34_0_0UMInternalModule>)pickInternalModuleImplementingInterface:(Protocol *)interface fromAmongModules:(NSArray<id<ABI34_0_0UMInternalModule>> *)internalModules;

@end
