import 'dart:async';

import 'package:camera/camera.dart';
import 'package:combien_g/pages/sign_in.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`

  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
      App(
      camera: firstCamera
    )
  );
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
              home: Center(
                child: Text(snapshot.error.toString(), style: FontUtils.contentDanger),
              )
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              home: SignIn(
                camera: widget.camera
              )
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Center(
            child: Text('Loading...', style: FontUtils.title),
          )
        );
      },
    );
  }
}

