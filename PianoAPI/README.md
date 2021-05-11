# Piano API for iOS

**Piano API for iOS** provides components for interacting with the [Anon Module API](https://docs.piano.io/)

## Requirements
- iOS 9.0+
- Xcode 12.0
- Swift 5.1

## Installation

### [CocoaPods](https://cocoapods.org/)

Add the following lines to your `Podfile`.

```
pod 'PianoAPI', '~>1.0.0'
```

## Configuration

### Endpoints:
```swift
PianoAPIEndpoint.production
PianoAPIEndpoint.productionAustralia
PianoAPIEndpoint.productionAsiaPacific
PianoAPIEndpoint.sandbox
```
### Initialize
```swift
// swift
PianoAPI.shared.initialize(endpoint: PianoAPIEndpoint.production)
```

```
// objective-c
[PianoAPI.shared initializeWithEndpoint:PianoAPIEndpoint.production];
```

## Usage

### Components:

```swift
PianoAPI.shared.access
PianoAPI.shared.accessToken
PianoAPI.shared.amp
PianoAPI.shared.anonAssets
PianoAPI.shared.anonError
PianoAPI.shared.anonMobileSdkIdDeployment
PianoAPI.shared.anonUser
PianoAPI.shared.conversion
PianoAPI.shared.conversionExternal
PianoAPI.shared.conversionRegistration
PianoAPI.shared.emailConfirmation
PianoAPI.shared.oauth
PianoAPI.shared.subscription
PianoAPI.shared.swgSync
```

### API function call:
```swift
// swift
PianoAPI.shared.anonMobileSdkIdDeployment.deploymentHost(aid: "<YOUR_AID>") { deploymentHost, error in
    if let e = error {
        ...
    }
    ...
}
```

```obj-c
// objective-c
[PianoAPI.shared.anonMobileSdkIdDeployment
    deploymentHostWithAid:@"<YOUR_AID>"
    completion:^(NSString * deploymentHost, NSError * error) {
    if (error != nil) {
        ...
    }
    ...
}];
```

### Optional scalar types (Bool, Int, Double):
For compatibility, the Piano API uses the OptionalBool, OptionalInt, and OptionalDouble types.

```swift
// swift
let optionalBoolValue: OptionalBool = true
let optionalIntValue: OptionalInt = 1
let optionalDoubleValue: OptionalDouble = 2.2

let boolValue: Bool = optionalBoolValue.value
let intValue: Int = optionalIntValue.value
let doubleValue: Double = optionalDoubleValue.value
```

```obj-c
// objective-c
OptionalBool *optionalBoolValue = [OptionalBool from:true];
OptionalInt *optionalIntValue = [OptionalInt from:1];
OptionalDouble *optionalDoublueValue = [OptionalDouble from:2.2];

BOOL boolValue = optionalBoolValue.value;
NSInteger intValue = optionalIntValue.value;
double doubleValue = optionalDoublueValue.value;
```
