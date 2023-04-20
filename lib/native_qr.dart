import 'native_qr_platform_interface.dart';

class NativeQr {
  Future<String?> get() {
    return NativeQrPlatform.instance.getQrCode();
  }
}
