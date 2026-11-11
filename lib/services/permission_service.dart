import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all essential media permissions for Video365
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final statuses = await [
      Permission.videos,
      Permission.photos,
      Permission.audio,
      Permission.storage,
      Permission.microphone,
      Permission.camera,
    ].request();

    // Check if at least media or storage is granted
    final hasMedia = statuses[Permission.videos]?.isGranted == true ||
        statuses[Permission.photos]?.isGranted == true ||
        statuses[Permission.storage]?.isGranted == true;

    return hasMedia;
  }

  /// Request microphone permission for voiceover recording
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}

