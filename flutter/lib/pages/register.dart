import 'package:camera/camera.dart';
import 'package:combien_g/models/authentication.dart';
import 'package:combien_g/pages/_app_router.dart';
import 'package:combien_g/pages/sign_in.dart';
import 'package:combien_g/utils/color_utils.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                      SizedBox(height: 32),
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
                            SizedBox(height: 16),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champs est requis';
                                }
                                return null;
                              },
                              controller: emailController,
                              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Adresse mail'),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champs est requis';
                                }
                                return null;
                              },
                              controller: passwordController,
                              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Mot de passe'),
                              //validatePassword,        //Function to check validation
                            ),
                            SizedBox(height: 32),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.blue,
                                    minimumSize: Size(double.infinity, 36),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
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
                                    minimumSize: Size(double.infinity, 36),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
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
