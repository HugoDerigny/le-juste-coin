import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

var storage = FirebaseStorage.instance;

enum CoinSide {
  OBVERSE,
  REVERSE
}


class Verification {
  static final Map<CoinSide, String> coinSidesMap = {
    CoinSide.OBVERSE: "OBVERSE",
    CoinSide.REVERSE: "REVERSE"
  };

  final String id;
  CoinSide side;
  int value;

  Verification(this.id, this.side, this.value);

  Future<String> getImageUrl() async {
    Reference ref = storage.ref().child('$id.jpg');

    return await ref.getDownloadURL();
  }

  String getFormattedCoinsInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(value / 100);
  }

  toJson() {
    return {
      "id": id,
      "side": coinSidesMap[side],
      "real_coin": value
    };
  }
}