import Constants from 'expo-constants';

export interface IFirebaseOptions {
  appId: string;
  apiKey: string;
  databaseURL: string;
  trackingId: string;
  messagingSenderId: string;
  storageBucket: string;
  projectId: string;
  authDomain: string;
  measurementId: string;
}

export function getDefaultWebOptions(): IFirebaseOptions | void {
  return Constants.manifest?.web?.config?.firebase;
}
