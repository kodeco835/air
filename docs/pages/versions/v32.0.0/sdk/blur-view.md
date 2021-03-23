---
title: BlurView
---

A React component that renders a native blur view on iOS and falls back to a semi-transparent view on Android. A common usage of this is for navigation bars, tab bars, and modals.

## Installation

This API is pre-installed in [managed](../../introduction/managed-vs-bare/#managed-workflow) apps. To use it in a [bare](../../introduction/managed-vs-bare/#bare-workflow) React Native app, follow its [installation instructions](https://github.com/expo/expo/tree/master/packages/expo-blur).

## Usage

import SnackEmbed from '~/components/plugins/SnackEmbed';

<SnackEmbed snackId="Bkbb_XnHW" />

<br />

<SnackEmbed snackId="BJM8eV3rZ" />

## API

```js
// in managed apps:
import { BlurView } from 'expo';

// in bare apps:
import { BlurView } from 'expo-blur';
```

## props

 `tint`
A string: `light`, `default`, or `dark`.

 `intensity`
A number from 1 to 100 to control the intensity of the blur effect.

#