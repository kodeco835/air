export type FacebookAuth = {
  /**
   * Access token for the authenticated session. This'll provide access to use with Facebook Graph API.
   */
  token: string;
  /**
   * The ID of the user.
   */
  userID: string;
  /**
   * Application ID used to initialize the FBSDK app.
   */
  appID: string;
  /**
   * List of granted permissions.
   */
  permissions?: string[];
  /**
   * List of requested permissions that the user has declined.
   */
  declinedPermissions?: string[];
  /**
   * List of permissions that were expired with this access token.
   */
  expiredPermissions?: string[];
  /**
   * Gets the time in milliseconds at which the `token` expires.
   */
  expires: number;
  /**
   * Time in milliseconds at which the current user data access expires.
   */
  dataAccessExpires: number;
  /**
   * The last time in milliseconds the `token` was refreshed (or when it was first obtained).
   */
  refresh?: number;

  /**
   * Android: Indicates how this `token` was obtained.
   */
  tokenSource?: string;
  /**
   * A valid raw signed request as a string.
   */
  signedRequest?: string;
  /**
   * A website domain within the Graph API.
   * https://developers.facebook.com/docs/graph-api/reference/v5.0/domain
   */
  graphDomain?: string;
};

export type FacebookLoginResult =
  | {
      type: 'cancel';
    }
  | ({
      type: 'success';
    } & FacebookAuth);

export type FacebookOptions = {
  permissions?: string[];
};

export type SDKScriptURLOptions = {
  /**
   * Web, Android: Sets the base Facebook domain to use when making Web requests.
   * Defaults to: 'connect.facebook.net'
   */
  domain?: string;
  /**
   * Web only: Chooses which language of the FBSDK bundle to use.
   * Defaults to: `'en_US'`
   */
  language?: string;
  /**
   * Web only: Enables the [customer chat plugin](https://developers.facebook.com/docs/messenger-platform/discovery/customer-chat-plugin/sdk/).
   * Defaults to `false`
   */
  isCustomerSupportChatEnabled?: boolean;
  /**
   * Web only: Loads the JS SDK in an non-minified format with more logs and stricter type checking.
   * This shouldn't be enabled in your production environment, as its payload is larger and is worse for the performance of your page.
   * Defaults to `false`
   */
  isDebugEnabled?: boolean;
};

export type SDKInitOptions = {
  /**
   * Application ID used to initialize the FBSDK app.
   * On web this is required, not providing it will result in a `ERR_FB_CONF` error.
   *
   * On native if you don't provide this, Facebook SDK will try to use `appId` from native
   * app resources (which in standalone apps you would define in `app.json`, in Expo client are unavailable, and in bare you configure yourself according to Facebook setup documentation for [iOS](https://developers.facebook.com/docs/facebook-login/ios#4--configure-your-project) and [Android](https://developers.facebook.com/docs/facebook-login/android#manifest)).
   * If it fails to find one, the promise will be rejected.
   */
  appId?: string;
  /**
   * Required for web. Selects the version of FBSDK to use.
   *
   * https://developers.facebook.com/docs/javascript/reference/FB.init/v5.0
   */
  version?: string;
  /**
   * Sets whether Facebook SDK should log app events. App events involve app eg. installs, app launches (more info [here](https://developers.facebook.com/docs/app-events/getting-started-app-events-android/#auto-events) and [here](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#auto-events)).
   * In some cases, you may want to disable or delay the collection of automatically logged events, such as to obtain user consent or fulfill legal obligations.
   * This method corresponds to [this](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#disable-auto-events) and [this](https://developers.facebook.com/docs/app-events/getting-started-app-events-android/#disable-auto-events) native SDK methods.
   */
  autoLogAppEvents?: boolean;
  /**
   * Web only: With xfbml set to true, the SDK will parse your page's DOM to find and initialize any social plugins that have been added using XFBML.
   * If you're not using social plugins on the page, setting `xfbml` to `false` will improve page load times.
   * You can find out more about this by looking at [Social Plugins](https://developers.facebook.com/docs/plugins/).
   * Defaults to `true`
   */
  xfbml?: boolean;
};

export type NativeInitOptions = {
  /**
   * An optional Facebook App Name argument for iOS and Android.
   */
  appName?: string;
};

export type InitOptions = SDKScriptURLOptions & SDKInitOptions & NativeInitOptions;
