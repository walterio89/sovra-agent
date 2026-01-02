import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceMetrics {
  static Future<Map<String, dynamic>> collectHeartbeat() async {
    final total = await DiskSpace.getTotalDiskSpace; // GB double
    final free = await DiskSpace.getFreeDiskSpace; // GB double

    int? totalBytes;
    int? freeBytes;
    if (total != null) totalBytes = (total * 1024 * 1024 * 1024).round();
    if (free != null) freeBytes = (free * 1024 * 1024 * 1024).round();

    final connectivity = await Connectivity().checkConnectivity();
    final networkType = connectivity.contains(ConnectivityResult.wifi)
        ? 'wifi'
        : connectivity.contains(ConnectivityResult.mobile)
        ? 'cell'
        : 'offline';

    final pkg = await PackageInfo.fromPlatform();

    return {
      'storage_total_bytes': totalBytes,
      'storage_free_bytes': freeBytes,
      'app_version': pkg.version,
      'network_type': networkType,
    };
  }

  static Future<Map<String, dynamic>> collectPairRequest() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;
    final pkg = await PackageInfo.fromPlatform();

    return {
      'platform': 'android',
      'type': 'phone',
      'os_version': 'Android ${android.version.release}',
      'hardware_model': '${android.manufacturer} ${android.model}',
      'app_version': pkg.version,
    };
  }
}
