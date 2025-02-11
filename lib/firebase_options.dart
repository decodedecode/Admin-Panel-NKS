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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDC-jj42UixeOpFmg6pZss5uka2g9pXFhc',
    appId: '1:202640147173:web:29fffcdd2be23d8d82ca0c',
    messagingSenderId: '202640147173',
    projectId: 'nkbs-bbf03',
    authDomain: 'nkbs-bbf03.firebaseapp.com',
    storageBucket: 'nkbs-bbf03.firebasestorage.app',
    measurementId: 'G-QM3BPC2V1V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFIxkzaFCCKPWZno1HHpz7az7gRdqPtjs',
    appId: '1:202640147173:android:6d1020ce7d39ec2b82ca0c',
    messagingSenderId: '202640147173',
    projectId: 'nkbs-bbf03',
    storageBucket: 'nkbs-bbf03.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8meVfEaOGm2erxYkMv5gw6rH4v2ytvZE',
    appId: '1:202640147173:ios:57f870736253f81982ca0c',
    messagingSenderId: '202640147173',
    projectId: 'nkbs-bbf03',
    storageBucket: 'nkbs-bbf03.firebasestorage.app',
    androidClientId: '202640147173-dqjkkbmj8b24n27kio6p1lomjvr5l8b2.apps.googleusercontent.com',
    iosClientId: '202640147173-t4elp4lq3n130ks8she6725edsgqjc29.apps.googleusercontent.com',
    iosBundleId: 'com.nks.nksAdmin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkOzWZS5UKX84ID8brOdQkhJLzj2jxFyU',
    appId: '1:202640147173:web:ad2499a438a232a282ca0c',
    messagingSenderId: '202640147173',
    projectId: 'nkbs-bbf03',
    authDomain: 'nkbs-bbf03.firebaseapp.com',
    storageBucket: 'nkbs-bbf03.firebasestorage.app',
    measurementId: 'G-MHXMLRQ5YF',
  );
}
