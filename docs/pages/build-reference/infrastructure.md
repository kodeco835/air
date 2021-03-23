---
title: Build server infrastructure
---

This document describes the current build infrastructure as of December 15, 2020. It is likely to change over time, and this document will be updated.

The software components will become customizable, but they aren't yet. So there is only one version of Node, yarn, CocoaPods, Xcode, Ruby, Fastlane, and so on currently available.

## JavaScript environment

- Node.js 14.15.1
- Yarn 1.22.10

## Android build server configuration

- Android workers run on Kubernetes in an isolated environment
  - Every build gets its own container running on a dedicated Kubernetes node
  - Build resources: 4 CPU, 16 GB RAM (14 GB after k8s overhead)
- Installed software:
  - Docker image: `ubuntu:bionic-20201119`
  - NDK 19.2.5345600
- NPM cache deployed with Kubernetes
- Maven cache deployed with Kubernetes, cached repositories:
  - `maven-central` - [https://repo1.maven.org/maven2/](https://repo1.maven.org/maven2/)
  - `google` - [https://maven.google.com/](https://maven.google.com/)
  - `android-tools` - [https://dl.bintray.com/android/android-tools/](https://dl.bintray.com/android/android-tools/)
  - `jcenter` - [https://jcenter.bintray.com/](https://jcenter.bintray.com/)
  - `plugins` - [https://plugins.gradle.org/m2/](https://plugins.gradle.org/m2/)

- Global gradle configuration in `~/.gradle/gradle.properties`:

  ```jsx
  org.gradle.jvmargs=-Xmx14g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
  org.gradle.parallel=true
  org.gradle.configureondemand=true
  org.gradle.daemon=false
  ```

## iOS build server configuration

- iOS worker VMs run on Macs Pro 6.1 in an isolated environement
  - Every build gets its own fresh macOS VM
  - Hardware: Intel(R) Xeon(R) CPU E5-2697 (12 core/24 threads), 64 GB RAM
  - Build resource limits: 6 cores, 8 GB RAM
- Installed software:
  - macOS Catalina 10.15.4
  - Xcode 12.1 (12A7403)
  - fastlane 2.170.0
  - CocoaPods 1.10.0
  - Ruby 2.6.3p62 (2019-04-16 revision 67580) [universal.x86_64-darwin19]
- NPM cache (temporary disabled)
