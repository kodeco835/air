/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#import <ABI40_0_0cxxreact/ABI40_0_0CxxModule.h>

namespace ABI40_0_0facebook {
namespace ABI40_0_0React {

/**
 * A sample CxxModule (legacy system) implementation.
 */
class SampleTurboCxxModuleLegacyImpl
    : public ABI40_0_0facebook::xplat::module::CxxModule {
 public:
  SampleTurboCxxModuleLegacyImpl();

  std::string getName() override;
  std::map<std::string, folly::dynamic> getConstants() override;
  std::vector<ABI40_0_0facebook::xplat::module::CxxModule::Method> getMethods() override;

  // API
  void voidFunc();
  bool getBool(bool arg);
  double getNumber(double arg);
  std::string getString(const std::string &arg);
  folly::dynamic getArray(const folly::dynamic &arg);
  folly::dynamic getObject(const folly::dynamic &arg);
  folly::dynamic
  getValue(double x, const std::string &y, const folly::dynamic &z);
  void getValueWithCallback(
      const ABI40_0_0facebook::xplat::module::CxxModule::Callback &callback);
  void getValueWithPromise(
      bool error,
      const ABI40_0_0facebook::xplat::module::CxxModule::Callback &resolve,
      const ABI40_0_0facebook::xplat::module::CxxModule::Callback &reject);
};

} // namespace ABI40_0_0React
} // namespace ABI40_0_0facebook
