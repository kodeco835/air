# Changelog

## Unpublished

### 🛠 Breaking changes

- Dropped support for iOS 10.0 ([#11344](https://github.com/expo/expo/pull/11344) by [@tsapeta](https://github.com/tsapeta))

### 🎉 New features

### 🐛 Bug fixes

## 1.4.0 — 2020-11-17

_This version does not introduce any user-facing changes._

## 1.3.0 — 2020-08-18

_This version does not introduce any user-facing changes._

## 1.2.0 — 2020-05-29

_This version does not introduce any user-facing changes._

## 1.1.0 — 2020-05-27

### 🐛 Bug fixes

- Fixed `appLoaderRegisteredForName` to not only check if a loader class name is in the cache for the provided name but also verifies that the cached and current class name match. When migrating from managed to bare, the class name cache needs to be updated. ([#8292](https://github.com/expo/expo/pull/8292) by [@thorbenprimke](https://github.com/thorbenprimke))
