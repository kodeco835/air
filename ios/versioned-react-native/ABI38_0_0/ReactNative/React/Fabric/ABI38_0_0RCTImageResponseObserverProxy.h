/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#import "ABI38_0_0RCTImageResponseDelegate.h"

#include <ABI38_0_0React/imagemanager/ImageResponseObserver.h>

NS_ASSUME_NONNULL_BEGIN

namespace ABI38_0_0facebook {
namespace ABI38_0_0React {

class ABI38_0_0RCTImageResponseObserverProxy final : public ImageResponseObserver {
 public:
  ABI38_0_0RCTImageResponseObserverProxy(id<ABI38_0_0RCTImageResponseDelegate> delegate = nil);

  void didReceiveImage(ImageResponse const &imageResponse) const override;
  void didReceiveProgress(float progress) const override;
  void didReceiveFailure() const override;

 private:
  __weak id<ABI38_0_0RCTImageResponseDelegate> delegate_;
};

} // namespace ABI38_0_0React
} // namespace ABI38_0_0facebook

NS_ASSUME_NONNULL_END
