// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAV_ecTr_AeRkLVEReIpXyFmVAzH_81QvQ',
    appId: '1:65822503237:web:7c5ecb284b4fb413e70e2c',
    messagingSenderId: '65822503237',
    projectId: 'clinikx-b1b1e',
    authDomain: 'clinikx-b1b1e.firebaseapp.com',
    storageBucket: 'clinikx-b1b1e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKJhlniLkcFBxyLbqKMRBFkMput3VLL2Q',
    appId: '1:65822503237:android:89785f472c445e20e70e2c',
    messagingSenderId: '65822503237',
    projectId: 'clinikx-b1b1e',
    storageBucket: 'clinikx-b1b1e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcp4IYQEinIBSMSUBwAUb8XOltrvzUXm4',
    appId: '1:65822503237:ios:8bb3aedf5cdaca75e70e2c',
    messagingSenderId: '65822503237',
    projectId: 'clinikx-b1b1e',
    storageBucket: 'clinikx-b1b1e.appspot.com',
    iosBundleId: 'com.example.clinikxDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAcp4IYQEinIBSMSUBwAUb8XOltrvzUXm4',
    appId: '1:65822503237:ios:8bb3aedf5cdaca75e70e2c',
    messagingSenderId: '65822503237',
    projectId: 'clinikx-b1b1e',
    storageBucket: 'clinikx-b1b1e.appspot.com',
    iosBundleId: 'com.example.clinikxDashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAV_ecTr_AeRkLVEReIpXyFmVAzH_81QvQ',
    appId: '1:65822503237:web:70bbd5e5b78097d8e70e2c',
    messagingSenderId: '65822503237',
    projectId: 'clinikx-b1b1e',
    authDomain: 'clinikx-b1b1e.firebaseapp.com',
    storageBucket: 'clinikx-b1b1e.appspot.com',
  );
}
