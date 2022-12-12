import 'package:flutter_test/flutter_test.dart';
import 'package:snappable/snappable.dart';
import 'package:snappable/snappable_platform_interface.dart';
import 'package:snappable/snappable_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSnappablePlatform
    with MockPlatformInterfaceMixin
    implements SnappablePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SnappablePlatform initialPlatform = SnappablePlatform.instance;

  test('$MethodChannelSnappable is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSnappable>());
  });

  test('getPlatformVersion', () async {
    Snappable snappablePlugin = Snappable();
    MockSnappablePlatform fakePlatform = MockSnappablePlatform();
    SnappablePlatform.instance = fakePlatform;

    expect(await snappablePlugin.getPlatformVersion(), '42');
  });
}
