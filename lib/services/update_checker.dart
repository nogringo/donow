import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateChecker {
  static const String githubRepo = 'nogringo/donow';
  
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Fetch latest release from GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        final downloadUrl = data['html_url'] ?? '';
        final body = data['body'] ?? '';
        
        // Compare versions
        final hasUpdate = _isNewerVersion(currentVersion, latestVersion);
        
        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          hasUpdate: hasUpdate,
          downloadUrl: downloadUrl,
          releaseNotes: body,
        );
      }
    } catch (e) {
      // Error checking for updates
    }
    return null;
  }
  
  static bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      for (int i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String downloadUrl;
  final String releaseNotes;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}