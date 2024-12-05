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

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuv_Whou1VSdWKHp5e5Le7svAKD3cGu0E',
    appId: '1:672571710112:web:7307c24d3a2b929e7fc7c5',
    messagingSenderId: '672571710112',
    projectId: 'tripplannerapp-700ea',
    authDomain: 'tripplannerapp-700ea.firebaseapp.com',
    storageBucket: 'tripplannerapp-700ea.firebasestorage.app',
    measurementId: 'G-GY6PBC1X5D',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvQIaGQHsPv9AHM9zzhWPOhIRsETXf9Ps',
    appId: '1:672571710112:android:d24e325bef927d3c7fc7c5',
    messagingSenderId: '672571710112',
    projectId: 'tripplannerapp-700ea',
    storageBucket: 'tripplannerapp-700ea.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJIhaxhXtQ2u8-CF_HE8-QOR5BjaYInMo',
    appId: '1:672571710112:ios:274d44fae6d737917fc7c5',
    messagingSenderId: '672571710112',
    projectId: 'tripplannerapp-700ea',
    storageBucket: 'tripplannerapp-700ea.firebasestorage.app',
    iosBundleId: 'com.example.tripPlannerApp',
  );

  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJIhaxhXtQ2u8-CF_HE8-QOR5BjaYInMo',
    appId: '1:672571710112:ios:274d44fae6d737917fc7c5',
    messagingSenderId: '672571710112',
    projectId: 'tripplannerapp-700ea',
    storageBucket: 'tripplannerapp-700ea.firebasestorage.app',
    iosBundleId: 'com.example.tripPlannerApp',
  );

  static final FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuv_Whou1VSdWKHp5e5Le7svAKD3cGu0E',
    appId: '1:672571710112:web:f46cb259d61e969d7fc7c5',
    messagingSenderId: '672571710112',
    projectId: 'tripplannerapp-700ea',
    authDomain: 'tripplannerapp-700ea.firebaseapp.com',
    storageBucket: 'tripplannerapp-700ea.firebasestorage.app',
    measurementId: 'G-93LY01CLXK',
  );
}