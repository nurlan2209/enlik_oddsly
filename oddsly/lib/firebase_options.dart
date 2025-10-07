import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ВСТАВЬ СЮДА СВОИ ДАННЫЕ ИЗ ШАГА 4
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBch-tNxEOxYFefi_IPgyr8TrSpKCpqjqY",
    authDomain: "oddsly-new.firebaseapp.com",
    projectId: "oddsly-new",
    storageBucket: "oddsly-new.firebasestorage.app",
    messagingSenderId: "184438312091",
    appId: "1:184438312091:web:fe94d4a13ea133b7938a3e"
  );
}
