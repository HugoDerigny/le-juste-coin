import 'dart:async';
import 'pages/sign_in.dart';
import 'utils/font_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// lancement de l'application
Future<void> main() async {
  // chargement des variables d'environnement depuis le fichier .env à la racine
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  // on récupère la caméra
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(App(camera: firstCamera));
}

class App extends StatefulWidget {
  const App({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Center(
                child: Text(snapshot.error.toString(),
                    style: FontUtils.contentDanger),
              ));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SignIn(camera: widget.camera));
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(
              child: Text('Loading...', style: FontUtils.title),
            ));
      },
    );
  }
}
