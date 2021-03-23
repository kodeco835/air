import './environment/validate.fx';
import './environment/logging.fx';
import './environment/LogBox.fx'; // This must be imported exactly here
import './environment/react-native-logs.fx';

// load expo-asset immediately to set a custom `source` transformer in React Native
import 'expo-asset';

import * as Font from 'expo-font';
import { installWebGeolocationPolyfill } from 'expo-location';
import * as React from 'react';
import { AppRegistry, Platform, StyleSheet } from 'react-native';

import DevAppContainer from './environment/DevAppContainer';

// add the dev app container wrapper component on ios
if (__DEV__) {
  if (Platform.OS === 'ios') {
    // @ts-ignore
    AppRegistry.setWrapperComponentProvider(() => DevAppContainer);

    // @ts-ignore
    const originalSetWrapperComponentProvider = AppRegistry.setWrapperComponentProvider;

    // @ts-ignore
    AppRegistry.setWrapperComponentProvider = provider => {
      function PatchedProviderComponent(props: any) {
        const ProviderComponent = provider();

        return (
          <DevAppContainer>
            <ProviderComponent {...props} />
          </DevAppContainer>
        );
      }

      originalSetWrapperComponentProvider(() => PatchedProviderComponent);
    };
  }
}

if (StyleSheet.setStyleAttributePreprocessor) {
  StyleSheet.setStyleAttributePreprocessor('fontFamily', Font.processFontFamily);
}

// polyfill navigator.geolocation
installWebGeolocationPolyfill();

// install globals
declare let module: any;

if (module && module.exports) {
  if (global) {
    const globals = require('./globals');

    // @ts-ignore
    global.__exponent = globals;
    // @ts-ignore
    global.__expo = globals;
    // @ts-ignore
    global.Expo = globals;
  }
}
