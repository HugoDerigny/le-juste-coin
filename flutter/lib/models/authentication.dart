import 'package:firebase_auth/firebase_auth.dart';

/// classe d'authentification firebase
class Authentication {
  /// notre utilisateur
  static User? user;

  /// inscrit un utilisateur via firebase, ou renvoie une erreur
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

  /// connecte un utilisateur avec le couple email/mot de passe
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

  /// déconnecte l'utilisateur
  static void logout() {
    FirebaseAuth.instance.signOut();
  }

  /// supprime le compte de l'utilisateur
  static void deleteAccount() {
    FirebaseAuth.instance.currentUser!.delete();
  }
}