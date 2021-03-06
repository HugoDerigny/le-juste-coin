import 'package:camera/camera.dart';
import '../models/authentication.dart';
import '../pages/_app_router.dart';
import '../pages/sign_in.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _RegisterState createState() => _RegisterState();
}

/// page de création de compte d'un utilisateur, accessible seulement
/// si l'utilisateur n'est pas connecté
class _RegisterState extends State<Register> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // controllers des champs
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// enregistre l'utilisateur sur firebase et l'amène sur le contenu
  /// de l'application
  void registerUser(BuildContext context) async {
    var authResponse = await Authentication.registerUsingEmailPassword(
      name: nameController.value.text,
      email: emailController.value.text,
      password: passwordController.value.text,
    );

    if (authResponse is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authResponse), backgroundColor: ColorUtils.danger));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppRouter(camera: widget.camera)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(12),
                child: Center(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      Text('Inscription', style: FontUtils.title),
                      const SizedBox(height: 32),
                      Form(
                        key: formkey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champs est requis';
                                }
                                return null;
                              },
                              controller: nameController,
                              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Prénom'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champs est requis';
                                }
                                return null;
                              },
                              autocorrect: false,
                              controller: emailController,
                              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Adresse mail'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champs est requis';
                                }
                                return null;
                              },
                              autocorrect: false,
                              controller: passwordController,
                              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Mot de passe'),
                              //validatePassword,        //Function to check validation
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.blue,
                                    minimumSize: const Size(double.infinity, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    )),
                                onPressed: () {
                                  if (formkey.currentState!.validate()) {
                                    registerUser(context);
                                  }
                                },
                                child: const Text("S'inscrire")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.gray,
                                    minimumSize: const Size(double.infinity, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    )),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignIn(camera: widget.camera)));
                                },
                                child: const Text("Se connecter", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))))
                          ],
                        ),
                      ),
                    ])))));
  }
}
