# Piano Composer integration with Cxense for iOS (C1X)

[![Version](https://img.shields.io/cocoapods/v/PianoC1X.svg?style=flat)](http://cocoapods.org/pods/PianoC1X)
[![Platform](https://img.shields.io/cocoapods/p/PianoC1X.svg?style=flat)](http://cocoapods.org/pods/PianoC1X)
[![License](https://img.shields.io/cocoapods/l/PianoC1X.svg?style=flat)](http://cocoapods.org/pods/PianoC1X)

> Important: Don't send Cxense PV events from screens with Composer

## Installation

### [CocoaPods](https://cocoapods.org/)

Add the following lines to your `Podfile`.

```
use_frameworks!

pod 'PianoC1X', '~>2.4.0'
```

## Import

```swift
import PianoC1X
```

## Configuration

```swift
let configuration = PianoC1XConfiguration(siteId: "<SITE_ID>")
```

## Enable integration

```swift
PianoC1X.enable(configuration: configuration)
```

## Usage
If integration is enabled, Composer will automatically send PV event to Cxense after execution.
> Important: You have to fill in url parameter for Composer:
>```swift
> PianoComposer(aid: ..., endpoint: ...)
>     ...
>     .url("https://example.com")
>     ...
>```
