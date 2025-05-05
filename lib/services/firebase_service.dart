// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:socialimpact/config/firebase_config.dart';

class FirebaseService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(  
          apiKey: firebaseConfig['apiKey']!,
          authDomain: firebaseConfig['authDomain']!,
          projectId: firebaseConfig['projectId']!,
          storageBucket: firebaseConfig['storageBucket']!,
          messagingSenderId: firebaseConfig['messagingSenderId']!,
          appId: firebaseConfig['appId']!,
          measurementId: firebaseConfig['measurementId']!,
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("Firebase initialized for ${kIsWeb ? 'web' : 'mobile'}");
  }
}