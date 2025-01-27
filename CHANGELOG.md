# Changelog

All changes to this project will be documented in this file.

## [1.3.1] - 2025-01-15

- Fix `Video` class `language` type


## [1.3.0] - 2024-10-29

- Fix `publishedAt` type in `Video` class
- Improve `Video` class members nullability
- Add `Video` class new members: `language`, `discardedAt`,...

## [1.2.4] - 2024-08-13

- Android: fix crash due to `ProxyLifecycleProvider` `getLifecycle`
- Android: upgrade dependencies

## [1.2.3] - 2024-07-09

- Android: fix crash on release due to minification
- Android: use plugin instead of imperative apply in `build.gradle`
- Override `toString` for `Video` class

## [1.2.2] - 2024-02-15

- iOS: improve returned error message
- Android: Upgrade to gradle 8, AGP and Kotlin to 1.9

## [1.2.1] - 2023-12-15

- Fix crash when targeting Android API level >= 34

## [1.2.0] - 2023-10-31

- Add upload with upload token and video id
- Add upload in background for Android through WorkManager
- Refactor Android and iOS to share the code with React Native

## [1.1.0] - 2022-07-05

- Add web support

## [1.0.0] - 2022-07-05

- Add API to set application name
- Use SDK name

## [0.1.1] - 2022-01-26

- Define the application name when instanciating native uploader libraries

## [0.1.0] - 2022-01-11

- Rename package to `video_uploader`
- Add `upload` by videoId
- Add progressive uploader
- Update to new Android and iOS video uploader

## [0.0.2] - 2021-09-09

- Initial release

