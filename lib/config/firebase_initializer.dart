import 'package:firebase_core/firebase_core.dart';
import 'package:cheer/firebase_options.dart';

class FirebaseInitializer {
  static Future<FirebaseApp> initialize() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
