import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'snappable_platform_interface.dart';

/// An implementation of [SnappablePlatform] that uses method channels.
class MethodChannelSnappable extends SnappablePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('snappable');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
