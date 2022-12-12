
import 'snappable_platform_interface.dart';

class Snappable {
  Future<String?> getPlatformVersion() {
    return SnappablePlatform.instance.getPlatformVersion();
  }
}
