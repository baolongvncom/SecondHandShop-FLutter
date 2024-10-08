// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyABHnKuwpsMj4OHIA3D3RaI0GPw17VP2rY',
    appId: '1:1043646690412:web:b2bf4ff510916a7648d449',
    messagingSenderId: '1043646690412',
    projectId: 'imageupload-demo-56fbe',
    authDomain: 'imageupload-demo-56fbe.firebaseapp.com',
    storageBucket: 'imageupload-demo-56fbe.appspot.com',
    measurementId: 'G-NJ814QTPTC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfD72bWvAV0BgJZzTkRxruqxfkk1tVAmk',
    appId: '1:1043646690412:android:74d8bd0350fa8ff648d449',
    messagingSenderId: '1043646690412',
    projectId: 'imageupload-demo-56fbe',
    storageBucket: 'imageupload-demo-56fbe.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCS7_yJSz0KG9wSF2rBhdr5ds6Mb4hhB3Q',
    appId: '1:1043646690412:ios:b9e20539b1fceea848d449',
    messagingSenderId: '1043646690412',
    projectId: 'imageupload-demo-56fbe',
    storageBucket: 'imageupload-demo-56fbe.appspot.com',
    iosBundleId: 'com.example.firebaseAuthTurtorial',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCS7_yJSz0KG9wSF2rBhdr5ds6Mb4hhB3Q',
    appId: '1:1043646690412:ios:4bc97477243a9d7548d449',
    messagingSenderId: '1043646690412',
    projectId: 'imageupload-demo-56fbe',
    storageBucket: 'imageupload-demo-56fbe.appspot.com',
    iosBundleId: 'com.example.firebaseAuthTurtorial.RunnerTests',
  );
}
