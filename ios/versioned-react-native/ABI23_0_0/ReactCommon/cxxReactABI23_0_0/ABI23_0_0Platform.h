// Copyright 2004-present Facebook. All Rights Reserved.

#pragma once

#include <functional>
#include <memory>
#include <string>

#include <cxxReactABI23_0_0/ABI23_0_0JSExecutor.h>
#include <cxxReactABI23_0_0/ABI23_0_0MessageQueueThread.h>
#include <ABI23_0_0jschelpers/ABI23_0_0JavaScriptCore.h>

#ifndef RN_EXPORT
#define RN_EXPORT __attribute__((visibility("default")))
#endif

namespace facebook {
namespace ReactABI23_0_0 {

namespace ReactABI23_0_0Marker {

enum ReactABI23_0_0MarkerId {
  NATIVE_REQUIRE_START,
  NATIVE_REQUIRE_STOP,
  RUN_JS_BUNDLE_START,
  RUN_JS_BUNDLE_STOP,
  CREATE_REACT_CONTEXT_STOP,
  JS_BUNDLE_STRING_CONVERT_START,
  JS_BUNDLE_STRING_CONVERT_STOP,
  NATIVE_MODULE_SETUP_START,
  NATIVE_MODULE_SETUP_STOP,
};

using LogTaggedMarker = std::function<void(const ReactABI23_0_0MarkerId, const char* tag)>;
extern RN_EXPORT LogTaggedMarker logTaggedMarker;

extern void logMarker(const ReactABI23_0_0MarkerId markerId);

}

namespace JSCNativeHooks {

using Hook = JSValueRef(*)(
  JSContextRef ctx,
  JSObjectRef function,
  JSObjectRef thisObject,
  size_t argumentCount,
  const JSValueRef arguments[],
  JSValueRef *exception);
extern RN_EXPORT Hook loggingHook;
extern RN_EXPORT Hook nowHook;

using ConfigurationHook = std::function<void(JSGlobalContextRef)>;
extern RN_EXPORT ConfigurationHook installPerfHooks;

}

} }
