// Copyright 2004-present Facebook. All Rights Reserved.

#pragma once

#include <memory>
#include <string>

#include <cxxReactABI26_0_0/ABI26_0_0ModuleRegistry.h>
#include <folly/Optional.h>
#include <ABI26_0_0jschelpers/ABI26_0_0Value.h>

namespace facebook {
namespace ReactABI26_0_0 {

/**
 * Holds and creates JS representations of the modules in ModuleRegistry
 */
class JSCNativeModules {

public:
  explicit JSCNativeModules(std::shared_ptr<ModuleRegistry> moduleRegistry);
  JSValueRef getModule(JSContextRef context, JSStringRef name);
  void reset();

private:
  folly::Optional<Object> m_genNativeModuleJS;
  std::shared_ptr<ModuleRegistry> m_moduleRegistry;
  std::unordered_map<std::string, Object> m_objects;

  folly::Optional<Object> createModule(const std::string& name, JSContextRef context);
};

}
}
