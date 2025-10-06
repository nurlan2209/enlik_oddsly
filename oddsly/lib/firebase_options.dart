// oddsly/lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Для мобильных платформ оставляем заглушки,
    // так как они используют свои файлы конфигурации.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // СЮДА НУЖНО ВСТАВИТЬ ВАШИ КЛЮЧИ ИЗ FIREBASE
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCkDMI_23X_NXiZ4McL4TyFc-GqDHXIyx0",
    authDomain: "oddsly-23574.firebaseapp.com",
    projectId: "oddsly-23574",
    storageBucket: "oddsly-23574.firebasestorage.app",
    messagingSenderId: "532449686757",
    appId: "1:532449686757:web:815b980a50724ae900100c",
    measurementId: "G-4EY1L7ZFVT"
  );
}
