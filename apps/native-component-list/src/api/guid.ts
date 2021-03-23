import * as Application from 'expo-application';
import { Platform } from 'react-native';

const map = {
  ios: {
    // bare-expo
    'dev.expo.Payments': '629683148649-uvkfsi3pckps3lc4mbc2mi7pna8pqej5',
    // NCL standalone
    'host.exp.nclexp': '29635966244-1vu5o3e9ucoh12ujlsjpn30kt3dbersv',
  },
  android: {
    // bare-expo
    'dev.expo.payments': '29635966244-knmlpr1upnv6rs4bumqea7hpit4o7kg2',
    // NCL standalone
    'host.exp.nclexp': '29635966244-lbejmv84iurcge3hn7fo6aapu953oivs',
  },
};
const GUIDs = Platform.select<Record<string, string>>(map);

export function getGUID(): string {
  // This should only happen
  if (!GUIDs) {
    throw new Error(
      `No valid GUID for bare projects on platform: ${
        Platform.OS
      }. Supported native platforms are currently: ${Object.keys(map).join(', ')}`
    );
  }

  if (!Application.applicationId) {
    throw new Error('Cannot get GUID with null `Application.applicationId`');
  }
  if (!(Application.applicationId in GUIDs)) {
    throw new Error(
      `No valid GUID for native app Id: ${Application.applicationId}. Valid GUIDs exist for ${
        Platform.OS
      } projects with native Id: ${Object.keys(GUIDs).join(', ')}`
    );
  }
  return GUIDs[Application.applicationId];
}
