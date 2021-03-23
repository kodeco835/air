//  Copyright © 2019 650 Industries. All rights reserved.

#import <ABI40_0_0EXUpdates/ABI40_0_0EXUpdatesAppLoader+Private.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ABI40_0_0EXUpdatesEmbeddedManifestName;
extern NSString * const ABI40_0_0EXUpdatesEmbeddedManifestType;
extern NSString * const ABI40_0_0EXUpdatesEmbeddedBundleFilename;
extern NSString * const ABI40_0_0EXUpdatesEmbeddedBundleFileType;
extern NSString * const ABI40_0_0EXUpdatesBareEmbeddedBundleFilename;
extern NSString * const ABI40_0_0EXUpdatesBareEmbeddedBundleFileType;

@interface ABI40_0_0EXUpdatesEmbeddedAppLoader : ABI40_0_0EXUpdatesAppLoader

+ (nullable ABI40_0_0EXUpdatesUpdate *)embeddedManifestWithConfig:(ABI40_0_0EXUpdatesConfig *)config
                                                database:(nullable ABI40_0_0EXUpdatesDatabase *)database;

- (void)loadUpdateFromEmbeddedManifestWithCallback:(ABI40_0_0EXUpdatesAppLoaderManifestBlock)manifestBlock
                                           success:(ABI40_0_0EXUpdatesAppLoaderSuccessBlock)success
                                             error:(ABI40_0_0EXUpdatesAppLoaderErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
