// Copyright © 2018 650 Industries. All rights reserved.

#import <Foundation/Foundation.h>
#import <ABI39_0_0UMCore/ABI39_0_0UMModuleRegistry.h>
#import <ABI39_0_0UMCore/ABI39_0_0UMSingletonModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABI39_0_0UMModuleRegistryProvider : NSObject

@property (nonatomic, weak) id<ABI39_0_0UMModuleRegistryDelegate> moduleRegistryDelegate;

+ (NSSet *)singletonModules;
+ (nullable ABI39_0_0UMSingletonModule *)getSingletonModuleForClass:(Class)singletonClass;

- (instancetype)initWithSingletonModules:(NSSet *)modules;
- (ABI39_0_0UMModuleRegistry *)moduleRegistry;

@end

NS_ASSUME_NONNULL_END
