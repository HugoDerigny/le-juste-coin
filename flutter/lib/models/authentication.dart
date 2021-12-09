import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  static User? user;

  static Future<dynamic> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;

      await user!.updateDisplayName(name);
      await user!.reload();

      user = auth.currentUser;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Mot de passe trop faible.';
        case 'email-already-in-use':
          return 'Adresse mail déjà enregistré.';
        default:
          return 'Une erreur est survenue : ' + e.code;
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<dynamic> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse mail non valide.';
        case 'user-not-found':
          return 'Aucun compte enregistré avec cet adresse mail.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        default:
          return 'Une erreur est survenue : ' + e.code;
      }
    }

    return user;
  }

  static void logout() {
    FirebaseAuth.instance.signOut();
  }

  static Future<User?> refreshUser() async {
    await user!.reload();
  }

  static bool isUserAuthentified() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      user = currentUser;
      return true;
    }

    return false;
  }
}