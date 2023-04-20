import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_qr/native_qr_method_channel.dart';

void main() {
  MethodChannelNativeQr platform = MethodChannelNativeQr();
  const MethodChannel channel = MethodChannel('native_qr');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getQrCode(), '42');
  });
}
