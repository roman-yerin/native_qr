import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_qr_method_channel.dart';

abstract class NativeQrPlatform extends PlatformInterface {
  /// Constructs a NativeQrPlatform.
  NativeQrPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeQrPlatform _instance = MethodChannelNativeQr();

  /// The default instance of [NativeQrPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeQr].
  static NativeQrPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeQrPlatform] when
  /// they register themselves.
  static set instance(NativeQrPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getQrCode() {
    throw UnimplementedError('getQrCode() has not been implemented.');
  }
}
