/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI34_0_0RCTImageManager.h"

#import <ReactABI34_0_0/ABI34_0_0RCTImageLoader.h>
#import <ReactABI34_0_0/imagemanager/ImageResponse.h>
#import <ReactABI34_0_0/imagemanager/ImageResponseObserver.h>

#import "ABI34_0_0RCTImagePrimitivesConversions.h"

using namespace facebook::ReactABI34_0_0;

@implementation ABI34_0_0RCTImageManager {
  ABI34_0_0RCTImageLoader *_imageLoader;
}

- (instancetype)initWithImageLoader:(ABI34_0_0RCTImageLoader *)imageLoader {
  if (self = [super init]) {
    _imageLoader = imageLoader;
  }

  return self;
}

- (ImageRequest)requestImage:(const ImageSource &)imageSource {
  auto imageRequest = ImageRequest(imageSource);

  auto observerCoordinator = imageRequest.getObserverCoordinator();

  NSURLRequest *request = NSURLRequestFromImageSource(imageSource);

  auto completionBlock = ^(NSError *error, UIImage *image) {
    if (image && !error) {
      auto imageResponse = ImageResponse(
          std::shared_ptr<void>((__bridge_retained void *)image, CFRelease));
      observerCoordinator->nativeImageResponseComplete(
          std::move(imageResponse));
    } else {
      observerCoordinator->nativeImageResponseFailed();
    }
  };

  auto progressBlock = ^(int64_t progress, int64_t total) {
    observerCoordinator->nativeImageResponseProgress(progress / (float)total);
  };

  ABI34_0_0RCTImageLoaderCancellationBlock cancelationBlock =
      [_imageLoader loadImageWithURLRequest:request
                                       size:CGSizeMake(
                                                imageSource.size.width,
                                                imageSource.size.height)
                                      scale:imageSource.scale
                                    clipped:YES
                                 resizeMode:ABI34_0_0RCTResizeModeStretch
                              progressBlock:progressBlock
                           partialLoadBlock:nil
                            completionBlock:completionBlock];

  std::function<void(void)> cancelationFunction = [cancelationBlock](void) {
    cancelationBlock();
  };

  imageRequest.setCancelationFunction(cancelationFunction);

  return imageRequest;
}

@end
