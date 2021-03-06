import 'package:camera/camera.dart';
import '../models/authentication.dart';
import '../pages/_app_router.dart';
import '../pages/register.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _SignInState createState() => _SignInState();
}

/// page d'authentification de l'utilisateur
class _SignInState extends State<SignIn> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // controlleurs des champs
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// authentifie un utilisateur via firebase et l'envoie sur la page
  /// du contenu principal
  void loginUser(BuildContext context) async {
    var authResponse = await Authentication.signInUsingEmailPassword(
      email: emailController.value.text,
      password: passwordController.value.text,
    );

    if (authResponse is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authResponse), backgroundColor: ColorUtils.danger));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AppRouter(camera: widget.camera)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(12),
                child: Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Text('Connexion', style: FontUtils.title),
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
                              autocorrect: false,
                              controller: emailController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Adresse mail'),
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
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Mot de passe'),
                              //validatePassword,        //Function to check validation
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.blue,
                                    minimumSize:
                                        const Size(double.infinity, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    )),
                                onPressed: () {
                                  if (formkey.currentState!.validate()) {
                                    loginUser(context);
                                  }
                                },
                                child: const Text("Se connecter")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.gray,
                                    minimumSize:
                                        const Size(double.infinity, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    )),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Register(camera: widget.camera)));
                                },
                                child: const Text("S'inscrire",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0))))
                          ],
                        ),
                      ),
                    ])
                )
            )
        )
    );
  }
}
