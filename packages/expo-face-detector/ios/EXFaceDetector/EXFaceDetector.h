//
//  EXFaceDetector.h
//  EXFaceDetector
//
//  Created by Michał Czernek on 12/04/2019.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <FirebaseMLVision/FirebaseMLVision.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXFaceDetector : NSObject

- (instancetype)initWithOptions:(FIRVisionFaceDetectorOptions *)options;
- (void)detectFromImage:(UIImage *)image completionListener:(void(^)(NSArray<FIRVisionFace *> *faces, NSError* error)) completion;
- (void)detectFromBuffer:(CMSampleBufferRef)buffer metadata:(FIRVisionImageMetadata *)metadata completionListener:(void(^)(NSArray<FIRVisionFace *> *faces, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
