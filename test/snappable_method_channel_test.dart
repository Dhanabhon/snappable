import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snappable/snappable_method_channel.dart';

void main() {
  MethodChannelSnappable platform = MethodChannelSnappable();
  const MethodChannel channel = MethodChannel('snappable');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
