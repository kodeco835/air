// load remote logging for compatability with custom development clients
import './environment/logging.fx';
import './environment/react-native-logs.fx';

// load expo-asset immediately to set a custom `source` transformer in React Native
import 'expo-asset';

import { NativeModulesProxy, Platform } from '@unimodules/core';
if (NativeModulesProxy.ExpoUpdates?.isMissingRuntimeVersion) {
  const message =
    'expo-updates is installed but there is no runtime or SDK version configured. ' +
    "You'll need to configure one of these two properties in " +
    Platform.select({ ios: 'Expo.plist', android: 'AndroidManifest.xml' }) +
    ' before OTA updates will work properly.';
  if (__DEV__) {
    console.warn(message);
  } else {
    throw new Error(message);
  }
}
