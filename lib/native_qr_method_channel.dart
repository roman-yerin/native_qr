import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_qr_platform_interface.dart';

/// An implementation of [NativeQrPlatform] that uses method channels.
class MethodChannelNativeQr extends NativeQrPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_qr');

  @override
  Future<String?> getQrCode() async {
    final qrJson = await methodChannel.invokeMethod<String>('getQrCode');
    return qrJson;
  }
}
