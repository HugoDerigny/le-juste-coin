import 'package:camera/camera.dart';
import '../models/authentication.dart';
import '../pages/sign_in.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// page de profile de l'utilisateur, très limité pour le moment
/// l'utilisateur a juste la possibilité de se déconnecter
class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;

    return Container(
        padding: const EdgeInsets.all(12),
        child: Center(
            child: Column(children: [
          const Text('Bienvenue'),
          const SizedBox(width: 5),
          Text(user!.displayName.toString(), style: FontUtils.title),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: ColorUtils.blue,
                  minimumSize: const Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )),
              onPressed: () {
                Authentication.logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => SignIn(camera: camera)));
              },
              child: const Text("Se déconnecter")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: ColorUtils.danger,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                  onPressed: () {
                    Authentication.deleteAccount();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => SignIn(camera: camera)));
                  },
                  child: const Text("Supprimer son compte"))
        ])));
  }
}
