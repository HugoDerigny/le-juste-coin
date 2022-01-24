import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

var storage = FirebaseStorage.instance;

/// côtés d'une pièce
enum CoinSide {
  /// côté pile
  obverse,
  /// côté face
  reverse
}


class Verification {
  /// map entre la valeur reçue en JSON et l'énumération
  static final Map<CoinSide, String> coinSidesMap = {
    CoinSide.obverse: "OBVERSE",
    CoinSide.reverse: "REVERSE"
  };

  /// id du détail de l'analyse
  final String id;
  /// véritable côté de la pièce
  CoinSide side;
  /// véritable valeur
  int value;

  Verification(this.id, this.side, this.value);

  /// renvoie le lien vers l'image lié à la pièce
  Future<String> getImageUrl() async {
    Reference ref = storage.ref().child('$id.jpg');

    return await ref.getDownloadURL();
  }

  /// renvoie la somme formatée en euros
  String getFormattedCoinsInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(value / 100);
  }

  /// serialize le modèle pour l'API
  toJson() {
    return {
      "id": id,
      "side": coinSidesMap[side],
      "real_coin": value
    };
  }
}