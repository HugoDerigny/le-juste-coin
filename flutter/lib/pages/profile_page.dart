import 'package:camera/camera.dart';
import '../models/authentication.dart';
import '../pages/sign_in.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          Text('Bienvenue'),
          SizedBox(width: 5),
          Text(user!.displayName.toString(), style: FontUtils.title),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: ColorUtils.danger,
                  minimumSize: Size(double.infinity, 36),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0),
                  )),
              onPressed: () {
                Authentication.logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => SignIn(camera: camera)));
              },
              child: const Text("Se déconnecter"))
        ])));
  }
}
