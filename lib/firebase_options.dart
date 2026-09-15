import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "scansafeafrica-boards.firebaseapp.com",
    projectId: "scansafeafrica-boards",
    storageBucket: "scansafeafrica-boards.firebasestorage.app",
    messagingSenderId: "130832397347",
    appId: "1:130832397347:web:1f0b7b98d56510e60f909d",
    measurementId: "G-9LF28329PL",
  );
}
