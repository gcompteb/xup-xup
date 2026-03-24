import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
  }
  
  if (!kIsWeb) {
    final notificationService = NotificationService();
    notificationService.setLocale(PlatformDispatcher.instance.locale);
    await notificationService.initialize();
    await notificationService.requestPermissions();
  }
  
  runApp(
    const ProviderScope(
      child: XupXupApp(),
    ),
  );
}
