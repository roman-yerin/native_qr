import 'package:flutter_test/flutter_test.dart';
import 'package:native_qr/native_qr.dart';
import 'package:native_qr/native_qr_platform_interface.dart';
import 'package:native_qr/native_qr_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeQrPlatform
    with MockPlatformInterfaceMixin
    implements NativeQrPlatform {
  @override
  Future<String?> getQrCode() {
    // TODO: implement getQrCode
    throw UnimplementedError();
  }
}

void main() {
  final NativeQrPlatform initialPlatform = NativeQrPlatform.instance;

  test('$MethodChannelNativeQr is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeQr>());
  });

  test('get', () async {
    NativeQr nativeQrPlugin = NativeQr();
    MockNativeQrPlatform fakePlatform = MockNativeQrPlatform();
    NativeQrPlatform.instance = fakePlatform;

    expect(await nativeQrPlugin.get(), '42');
  });
}
