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
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAUJB-SEWDsO0TpeMiuP9DoO3U_jlncaeo',
    appId: '1:612503210659:android:6685e6251e7b7f8de28d16',
    messagingSenderId: '612503210659',
    projectId: 'xup-xup',
    authDomain: 'xup-xup.firebaseapp.com',
    storageBucket: 'xup-xup.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUJB-SEWDsO0TpeMiuP9DoO3U_jlncaeo',
    appId: '1:612503210659:android:6685e6251e7b7f8de28d16',
    messagingSenderId: '612503210659',
    projectId: 'xup-xup',
    storageBucket: 'xup-xup.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAvq2P1KNLlFJ9cVuHfiXh1UqEXux_jaE',
    appId: '1:612503210659:ios:81ce1391c9def7ace28d16',
    messagingSenderId: '612503210659',
    projectId: 'xup-xup',
    storageBucket: 'xup-xup.firebasestorage.app',
    iosBundleId: 'com.xupxup.xupXup',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDAvq2P1KNLlFJ9cVuHfiXh1UqEXux_jaE',
    appId: '1:612503210659:ios:81ce1391c9def7ace28d16',
    messagingSenderId: '612503210659',
    projectId: 'xup-xup',
    storageBucket: 'xup-xup.firebasestorage.app',
    iosBundleId: 'com.xupxup.xupXup',
  );
}
