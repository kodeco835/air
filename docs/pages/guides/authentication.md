---
title: Authentication
---

import PlatformsSection from '~/components/plugins/PlatformsSection';
import InstallSection from '~/components/plugins/InstallSection';
import TableOfContentSection from '~/components/plugins/TableOfContentSection';
import { SocialGrid, SocialGridItem, CreateAppButton } from '~/components/plugins/AuthSessionElements';
import TerminalBlock from '~/components/plugins/TerminalBlock';
import SnackInline from '~/components/plugins/SnackInline';

Expo can be used to login to many popular providers on iOS, Android, and web! Most of these guides utilize the pure JS [`AuthSession` API](/versions/latest/sdk/auth-session), refer to those docs for more information on the API.

<TableOfContentSection title="Table of contents" contents={[
"Guides",
"Redirect URI patterns",
]} />

## Guides

**AuthSession** can be used for any OAuth or OpenID Connect provider, we've assembled guides for using the most requested services!
If you'd like to see more, you can [open a PR](https://github.com/expo/expo/edit/master/docs/pages/guides/authentication.md) or [vote on canny](https://expo.canny.io/feature-requests).

<SocialGrid>
  <SocialGridItem title="Identity 4" protocol={['OAuth 2', 'OpenID']} href="#identity-4" image="/static/images/sdk/auth-session/identity4.png" />
  <SocialGridItem title="Azure" protocol={['OAuth 2', 'OpenID']} href="#azure" image="/static/images/sdk/auth-session/azure.png" />
  <SocialGridItem title="Apple" protocol={['iOS Only']} href="/versions/latest/sdk/apple-authentication" image="/static/images/sdk/auth-session/apple.png" />
  <SocialGridItem title="Coinbase" protocol={['OAuth 2']} href="#coinbase" image="/static/images/sdk/auth-session/coinbase.png" />
  <SocialGridItem title="Facebook" protocol={['OAuth 2']} href="#facebook" image="/static/images/sdk/auth-session/facebook.png" />
  <SocialGridItem title="Fitbit" protocol={['OAuth 2']} href="#fitbit" image="/static/images/sdk/auth-session/fitbit.png" />
  <SocialGridItem title="Firebase Phone" protocol={['Recaptcha']} href="/versions/latest/sdk/firebase-recaptcha" image="/static/images/sdk/auth-session/firebase-phone.png" />
  <SocialGridItem title="Github" protocol={['OAuth 2']} href="#github" image="/static/images/sdk/auth-session/github.png" />
  <SocialGridItem title="Google" protocol={['OAuth 2', 'OpenID']} href="#google" image="/static/images/sdk/auth-session/google.png" />
  <SocialGridItem title="Okta" protocol={['OAuth 2', 'OpenID']} href="#okta" image="/static/images/sdk/auth-session/okta.png" />
  <SocialGridItem title="Reddit" protocol={['OAuth 2']} href="#reddit" image="/static/images/sdk/auth-session/reddit.png" />
  <SocialGridItem title="Slack" protocol={['OAuth 2']} href="#slack" image="/static/images/sdk/auth-session/slack.png" />
  <SocialGridItem title="Spotify" protocol={['OAuth 2']} href="#spotify" image="/static/images/sdk/auth-session/spotify.png" />
  <SocialGridItem title="Uber" protocol={['OAuth 2']} href="#uber" image="/static/images/sdk/auth-session/uber.png" />
</SocialGrid>

<br />

### Identity 4

| Website                  | Provider | PKCE     | Auto Discovery |
| ------------------------ | -------- | -------- | -------------- |
| [More Info][c-identity4] | OpenID   | Required | Available      |

[c-identity4]: https://demo.identityserver.io/

- If `offline_access` isn't included then no refresh token will be returned.

<SnackInline label='Identity 4 Auth' dependencies={['expo-auth-session', 'expo-web-browser']}>

```tsx
import React from 'react';
import { Button, Platform, Text, View } from 'react-native';
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { Linking } from 'expo';

/* @info <strong>Web only:</strong> This method should be invoked on the page that the auth popup gets redirected to on web, it'll ensure that authentication is completed properly. On native this does nothing. */
if (Platform.OS === 'web') {
  WebBrowser.maybeCompleteAuthSession();
}
/* @end */

/* @info Using the Expo proxy will redirect the user through auth.expo.io enabling you to use web links when configuring your project with an OAuth provider. This is not available on web. */
const useProxy = true;
/* @end */

const redirectUri = AuthSession.makeRedirectUri({
  /* @info You need to manually define the redirect URI, in Expo this should match the value of <code>scheme</code> in your app.config.js or app.json . */
  native: 'your.app://redirect',
  /* @end */
  useProxy,
});

export default function App() {
  /* @info If the provider supports auto discovery then you can pass an issuer to the `useAutoDiscovery` hook to fetch the discovery document. */
  const discovery = AuthSession.useAutoDiscovery('https://demo.identityserver.io');
  /* @end */

  // Create and load an auth request
  const [request, result, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: 'native.code',
      /* @info After a user finishes authenticating, the server will redirect them to this URI. Learn more about <a href="../../workflow/linking/">linking here</a>. */
      redirectUri,
      /* @end */
      scopes: ['openid', 'profile', 'email', 'offline_access'],
    },
    discovery
  );

  return (
    <>
      <Button title="Login!" disabled={!request} onPress={() => promptAsync({ useProxy })} />
      {result && <Text>{JSON.stringify(result, null, 2)}</Text>}
    </>
  );
}
```

</SnackInline>

<!-- End Identity 4 -->

### Azure

<CreateAppButton name="Azure" href="https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview" />

| Website                     | Provider | PKCE      | Auto Discovery |
| --------------------------- | -------- | --------- | -------------- |
| [Get Your Config][c-azure2] | OpenID   | Supported | Available      |

[c-azure2]: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview

```ts
// Endpoint
const discovery = useAutoDiscovery('https://login.microsoftonline.com/<TENANT_ID>/v2.0');
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['openid', 'profile', 'email', 'offline_access'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Azure -->

### Coinbase

<CreateAppButton name="Coinbase" href="https://www.coinbase.com/oauth/applications/new" />

| Website                       | Provider  | PKCE      | Auto Discovery |
| ----------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-coinbase] | OAuth 2.0 | Supported | Not Available  |

[c-coinbase]: https://www.coinbase.com/oauth/applications/new

- You cannot use the Expo proxy because they don't allow `@` in their redirect URIs.
- The `redirectUri` requires 2 slashes (`://`).
- Scopes must be joined with ':' so just create one long string.

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://www.coinbase.com/oauth/authorize',
  tokenEndpoint: 'https://api.coinbase.com/oauth/token',
  revocationEndpoint: 'https://api.coinbase.com/oauth/revoke',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['wallet:accounts:read'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Coinbase -->

### Facebook

<CreateAppButton name="Facebook" href="https://developers.facebook.com/" />

| Website                 | Provider | PKCE      | Auto Discovery |
| ----------------------- | -------- | --------- | -------------- |
| [More Info][c-facebook] | OAuth    | Supported | Not Available  |

[c-facebook]: https://developers.facebook.com/

> You can use the [`expo-facebook`](/versions/latest/sdk/expo-facebook) to authenticate via the Facebook app, however this functionality is limited.

- Learn more about [manually building a login flow](https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow/).
- Native auth isn't available in the App/Play Store client because you need a custom URI scheme built into the bundle. The custom scheme provided by Facebook is `fb` followed by the **project ID** (ex: `fb145668956753819`):
  - **Standalone:**
    - Add `facebookScheme: 'fb<YOUR FBID>'` to your `app.config.js` or `app.json`
    - You'll need to make a new production build to bundle these values `expo build:ios` & `expo build:android`.
  - **Bare:**
    - Run `npx uri-scheme add fb<YOUR FBID>`
    - Rebuild with `yarn ios` & `yarn android`
- You can still test native auth in the client by using the Expo proxy `useProxy`
- The `native` redirect URI **must** be formatted like `fbYOUR_NUMERIC_ID://authorize`
  - If the protocol/suffix is not your FBID then you will get an error like: `No redirect URI in the params: No redirect present in URI`.
  - If the path is not `://authorize` then you will get an error like: `Can't Load URL: The domain of this URL isn't included in the app's domains. To be able to load this URL, add all domains and subdomains of your app to the App Domains field in your app settings.`

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://www.facebook.com/v6.0/dialog/oauth',
  tokenEndpoint: 'https://graph.facebook.com/v6.0/oauth/access_token',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: '<YOUR FBID>',
    scopes: ['public_profile', 'user_likes'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      // Use your FBID here. The path MUST be `authorize`.
      native: 'fb111111111111://authorize',
    }),
    extraParams: {
      // Use `popup` on web for a better experience
      display: Platform.select({ web: 'popup' }),
      // Optionally you can use this to rerequest declined permissions
      auth_type: 'rerequest',
    },
  },
  discovery
);
```

<!-- End Facebook -->

### FitBit

<CreateAppButton name="FitBit" href="https://dev.fitbit.com/apps/new" />

| Website                     | Provider  | PKCE      | Auto Discovery |
| --------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-fitbit] | OAuth 2.0 | Supported | Not Available  |

[c-fitbit]: https://dev.fitbit.com/apps/new

- Provider only allows one redirect URI per app. You'll need an individual app for every method you want to use:
  - Expo Client: `exp://localhost:19000/--/*`
  - Expo Client + Proxy: `https://auth.expo.io/@you/your-app`
  - Standalone or Bare: `com.your.app://*`
  - Web: `https://yourwebsite.com/*`
- The `redirectUri` requires 2 slashes (`://`).

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://www.fitbit.com/oauth2/authorize',
  tokenEndpoint: 'https://api.fitbit.com/oauth2/token',
  revocationEndpoint: 'https://api.fitbit.com/oauth2/revoke',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['activity', 'sleep'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End FitBit -->

### GitHub

<CreateAppButton name="Github" href="https://github.com/settings/developers" />

| Website                     | Provider  | PKCE      | Auto Discovery |
| --------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-github] | OAuth 2.0 | Supported | Not Available  |

[c-github]: https://github.com/settings/developers

- Provider only allows one redirect URI per app. You'll need an individual app for every method you want to use:
  - Expo Client: `exp://localhost:19000/--/*`
  - Expo Client + Proxy: `https://auth.expo.io/@you/your-app`
  - Standalone or Bare: `com.your.app://*`
  - Web: `https://yourwebsite.com/*`
- The `redirectUri` requires 2 slashes (`://`).
- `revocationEndpoint` is dynamic and requires your `config.clientId`.

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://github.com/login/oauth/authorize',
  tokenEndpoint: 'https://github.com/login/oauth/access_token',
  revocationEndpoint: 'https://github.com/settings/connections/applications/<CLIENT_ID>',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['identity'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Github -->

### Google

<CreateAppButton name="Google" href="https://developers.google.com/identity/protocols/OAuth2" />

| Website                     | Provider | PKCE      | Auto Discovery |
| --------------------------- | -------- | --------- | -------------- |
| [Get Your Config][c-google] | OpenID   | Supported | Available      |

[c-google]: https://developers.google.com/identity/protocols/OAuth2

- Google will provide you with a custom `redirectUri` which you **cannot** use in the Expo client.
  - URI schemes must be built into the app, you can do this with **bare workflow, standalone, and custom clients**.
  - You can still develop and test Google auth in the Expo client with the proxy service, just be sure to configure the project as a website in the Google developer console.
- For a slightly more native experience in bare Android apps, you can use the [`expo-google-sign-in`](/versions/latest/sdk/google-sign-in) package.
- You can change the UI language by setting `extraParams.hl` to an ISO language code (ex: `fr`, `en-US`). Defaults to the best estimation based on the users browser.
- You can set which email address to use ahead of time by setting `extraParams.login_hint`.

```ts
// Endpoint
const discovery = useAutoDiscovery('https://accounts.google.com');
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'com.googleusercontent.apps.GOOGLE_GUID://redirect',
      useProxy,
    }),
    scopes: ['openid', 'profile'],

    // Optionally should the user be prompted to select or switch accounts
    prompt: Prompt.SelectAccount,

    // Optional
    extraParams: {
      // Change language
      hl: 'fr',
      // Select the user
      login_hint: 'user@gmail.com',
    },
    scopes: ['openid', 'profile'],
  },
  discovery
);
```

<!-- End Google -->

### Okta

<CreateAppButton name="Okta" href="https://developer.okta.com/signup" />

| Website                          | Provider | PKCE      | Auto Discovery |
| -------------------------------- | -------- | --------- | -------------- |
| [Sign-up][c-okta] > Applications | OpenID   | Supported | Available      |

[c-okta]: https://developer.okta.com/signup/

- You cannot define a custom `redirectUri`, Okta will provide you with one.
- You can use the Expo proxy to test this without a native rebuild, just be sure to configure the project as a website.

```ts
// Endpoint
const discovery = useAutoDiscovery('https://<OKTA_DOMAIN>.com/oauth2/default');
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['openid', 'profile'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'com.okta.<OKTA_DOMAIN>:/callback',
      useProxy,
    }),
  },
  discovery
);
```

<!-- End Okta -->

### Reddit

<CreateAppButton name="Reddit" href="https://www.reddit.com/prefs/apps" />

| Website                     | Provider  | PKCE      | Auto Discovery |
| --------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-reddit] | OAuth 2.0 | Supported | Not Available  |

[c-reddit]: https://www.reddit.com/prefs/apps

- Provider only allows one redirect URI per app. You'll need an individual app for every method you want to use:
  - Expo Client: `exp://localhost:19000/--/*`
  - Expo Client + Proxy: `https://auth.expo.io/@you/your-app`
  - Standalone or Bare: `com.your.app://*`
  - Web: `https://yourwebsite.com/*`
- The `redirectUri` requires 2 slashes (`://`).

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://www.reddit.com/api/v1/authorize.compact',
  tokenEndpoint: 'https://www.reddit.com/api/v1/access_token',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['identity'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Reddit -->

### Slack

<CreateAppButton name="Slack" href="https://api.slack.com/apps" />

| Website                    | Provider  | PKCE      | Auto Discovery |
| -------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-slack] | OAuth 2.0 | Supported | Not Available  |

[c-slack]: https://api.slack.com/apps

- The `redirectUri` requires 2 slashes (`://`).
- `redirectUri` can be defined under the "OAuth & Permissions" section of the website.
- `clientId` and `clientSecret` can be found in the **"App Credentials"** section.
- Scopes must be joined with ':' so just create one long string.
- Navigate to the **"Scopes"** section to enable scopes.
- `revocationEndpoint` is not available.

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://slack.com/oauth/authorize',
  tokenEndpoint: 'https://slack.com/api/oauth.access',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['emoji:read'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Slack -->

### Spotify

<CreateAppButton name="Spotify" href="https://developer.spotify.com/dashboard/applications" />

| Website                      | Provider  | PKCE      | Auto Discovery |
| ---------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-spotify] | OAuth 2.0 | Supported | Not Available  |

[c-spotify]: https://developer.spotify.com/dashboard/applications

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://accounts.spotify.com/authorize',
  tokenEndpoint: 'https://accounts.spotify.com/api/token',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['user-read-email', 'playlist-modify-public'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Spotify -->

### Uber

<CreateAppButton name="Uber" href="https://developer.uber.com/docs/riders/guides/authentication/introduction" />

| Website                   | Provider  | PKCE      | Auto Discovery |
| ------------------------- | --------- | --------- | -------------- |
| [Get Your Config][c-uber] | OAuth 2.0 | Supported | Not Available  |

[c-uber]: https://developer.uber.com/docs/riders/guides/authentication/introduction

- The `redirectUri` requires 2 slashes (`://`).
- `scopes` can be difficult to get approved.

```ts
// Endpoint
const discovery = {
  authorizationEndpoint: 'https://login.uber.com/oauth/v2/authorize',
  tokenEndpoint: 'https://login.uber.com/oauth/v2/token',
  revocationEndpoint: 'https://login.uber.com/oauth/v2/revoke',
};
// Request
const [request, response, promptAsync] = useAuthRequest(
  {
    clientId: 'CLIENT_ID',
    scopes: ['profile', 'delivery'],
    // For usage in managed apps using the proxy
    redirectUri: makeRedirectUri({
      // For usage in bare and standalone
      native: 'your.app://redirect',
    }),
  },
  discovery
);
```

<!-- End Uber -->

<!-- End Guides -->

## Redirect URI patterns

Here are a few examples of some common redirect URI patterns you may end up using.

#### Expo Proxy

> `https://auth.expo.io/@yourname/your-app`

- **Environment:** Development or production projects in the Expo client, or in a standalone build.
- **Create:** Use `AuthSession.makeRedirectUri({ useProxy: true })` to create this URI.
  - The link is constructed from your Expo username and the Expo app name, which are appended to the proxy website.
- **Usage:** `promptAsync({ useProxy: true, redirectUri })`

#### Published project in the Expo Client

> `exp://exp.host/@yourname/your-app`

- **Environment:** Production projects that you `expo publish`'d and opened in the Expo client.
- **Create:** Use `AuthSession.makeRedirectUri({ useProxy: false })` to create this URI.
  - The link is constructed from your Expo username and the Expo app name, which are appended to the Expo client URI scheme.
  - You could also create this link with using `Linking.makeUrl()` from `expo-linking`.
- **Usage:** `promptAsync({ redirectUri })`

#### Development project in the Expo client

> `exp://localhost:19000`

- **Environment:** Development projects in the Expo client when you run `expo start`.
- **Create:** Use `AuthSession.makeRedirectUri({ useProxy: false })` to create this URI.
  - This link is built from your Expo server's `port` + `host`.
  - You could also create this link with using `Linking.makeUrl()` from `expo-linking`.
- **Usage:** `promptAsync({ redirectUri })`

#### Standalone, Bare, or Custom

> `yourscheme://path`

In some cases there will be anywhere between 1 to 3 slashes (`/`).

- **Environment:**
  - Bare-workflow - React Native + Unimodules.
    - `npx create-react-native-app` or `expo eject`
  - Standalone builds in the App or Play Store
    - `expo build:ios` or `expo build:android`
  - Custom Expo client builds
    - `expo client:ios`
- **Create:** Use `AuthSession.makeRedirectUri({ native: '<YOUR_URI>' })` to select native when running in the correct environment.
  - This link must be hard coded because it cannot be inferred from the config reliably, with exception for Standalone builds using `scheme` from `app.config.js` or `app.json`. Often this will be used for providers like Google or Okta which require you to use a custom native URI redirect. You can add, list, and open URI schemes using `npx uri-scheme`.
  - If you change the `expo.scheme` after ejecting then you'll need to use the `expo apply` command to apply the changes to your native project, then rebuild them (`yarn ios`, `yarn android`).
- **Usage:** `promptAsync({ redirectUri })`

[userinfo]: https://openid.net/specs/openid-connect-core-1_0.html#UserInfo
[provider-meta]: https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata
[oidc-dcr]: https://openid.net/specs/openid-connect-discovery-1_0.html#OpenID.Registration
[oidc-autherr]: https://openid.net/specs/openid-connect-core-1_0.html#AuthError
[oidc-authreq]: https://openid.net/specs/openid-connect-core-1_0.html#AuthorizationRequest
[opmeta]: https://openid.net/specs/openid-connect-session-1_0-17.html#OPMetadata
[s1012]: https://tools.ietf.org/html/rfc6749#section-10.12
[s62]: https://tools.ietf.org/html/rfc7636#section-6.2
[s52]: https://tools.ietf.org/html/rfc6749#section-5.2
[s421]: https://tools.ietf.org/html/rfc6749#section-4.2.1
[s42]: https://tools.ietf.org/html/rfc7636#section-4.2
[s411]: https://tools.ietf.org/html/rfc6749#section-4.1.1
[s311]: https://tools.ietf.org/html/rfc6749#section-3.1.1
[s311]: https://tools.ietf.org/html/rfc6749#section-3.1.1
[s312]: https://tools.ietf.org/html/rfc6749#section-3.1.2
[s33]: https://tools.ietf.org/html/rfc6749#section-3.3
[s32]: https://tools.ietf.org/html/rfc6749#section-3.2
[s231]: https://tools.ietf.org/html/rfc6749#section-2.3.1
[s22]: https://tools.ietf.org/html/rfc6749#section-2.2
[s21]: https://tools.ietf.org/html/rfc7009#section-2.1
[s31]: https://tools.ietf.org/html/rfc6749#section-3.1
[pkce]: https://oauth.net/2/pkce/
