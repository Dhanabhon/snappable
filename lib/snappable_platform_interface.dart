import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'snappable_method_channel.dart';

abstract class SnappablePlatform extends PlatformInterface {
  /// Constructs a SnappablePlatform.
  SnappablePlatform() : super(token: _token);

  static final Object _token = Object();

  static SnappablePlatform _instance = MethodChannelSnappable();

  /// The default instance of [SnappablePlatform] to use.
  ///
  /// Defaults to [MethodChannelSnappable].
  static SnappablePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SnappablePlatform] when
  /// they register themselves.
  static set instance(SnappablePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
