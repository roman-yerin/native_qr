# native_qr

The simplest QR code scanner for Flutter ever.

This is the thin wrapper for the native IOS and Android OS provided QR code scanners. If you need just scan one QR code and proceed with the result, this plugin is all you need.

## Getting Started

1) Install the plugin.

```shell
$ flutter pub add native_qr
```

2. Import it.
```dart
import 'package:native_qr/native_qr.dart';
```

3. Call the get() method.

```dart
try {
  NativeQr nativeQr = NativeQr();
  String? result = await nativeQr.get();  
} catch(err) {
  print(err);
}

```

## Platform notes

### IOS

Camera permission is required, so `Privacy - Camera Usage Description` aka `NSCameraUsageDescription` has to be set in your Info.plist

IOS implementation uses [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller), which is available since version 16.0, so you have to set project deployment target to 16.0 to use this plugin.

The running device must have the A12 Bionic chip or later.

If your app requires Live Text for its core functionality, you can make your app available only on devices that support Live Text. Add the [`UIRequiredDeviceCapabilities`](https://developer.apple.com/documentation/bundleresources/information_property_list/uirequireddevicecapabilities) key to your app’s information property list and include the `iphone-ipad-minimum-performance-a12` subkey in the array of device capabilities.

### Android

Minimum project requirements are:

```gradle
minSdkVersion 21
targetSdkVersion 33
```

Android implementation uses [GmsBarcodeScanner](https://developers.google.com/android/reference/com/google/mlkit/vision/codescanner/GmsBarcodeScanner?hl=ru) which is based on Google play services. To load it automatically you have to add the following to your application AndroidManifest.xml, otherwise the very first scan attempts will fail while Android is downloading the scanner.

```xml
<application ...>
  ...
  <meta-data
      android:name="com.google.mlkit.vision.DEPENDENCIES"
      android:value="barcode_ui"/>
  ...
</application>
```

## Error handling

The plugin either returnes the scanned data or throws an exception that is one of the following.

1. **CANCELED**: scanning operation has been canceled
1. **ERROR**: some error happened
1. **UNKNOWN**: God knows what happened and you highly likely will never see this type of error

## Limitations and known issues

1. Only QR codes supported (can be changed in case it is needed, open a feature request on Github)
2. IOS implementation since 16.0 (which is >90% of the market share as for May, 2023)
3. Only string representation of QR encoded data is provided
4. The result will be only one QR in the camera's field of view, which one is unpredictable
5. IOS multiscene apps unsupported, the plugin uses the first scene to present the camera view
