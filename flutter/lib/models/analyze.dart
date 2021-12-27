import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

enum ImageType {
  ORIGINAL,
  BLURRED,
  DILATED,
  ERODED,
  CANNY,
  CIRCLES
}

var storage = FirebaseStorage.instance;

class Analyze {
  final String id;
  final DateTime createdAt;
  final int sumInCents;
  final int averageConfidence;
  final List<AnalyzedItem> items;

  static final images = {
    ImageType.ORIGINAL: 'original',
    ImageType.BLURRED: 'blur',
    ImageType.DILATED: 'dilate',
    ImageType.ERODED: 'erode',
    ImageType.CANNY: 'canny',
    ImageType.CIRCLES: 'circles'
  };

  Analyze(this.id, this.createdAt, this.sumInCents, this.averageConfidence,
      this.items);

  Analyze.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['created_at']),
      sumInCents = json['sum_of_coins'],
      averageConfidence = json['average_confidence'],
      items = List<AnalyzedItem>.from(json['items'].map((item) => AnalyzedItem.fromJson(item)));

  String getDateFormatted() {
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    return formatter.format(createdAt);
  }

  String getFullDateFormatted() {
    DateFormat formatter = DateFormat('dd/MM/yyyy à hh:mm');

    return formatter.format(createdAt);
  }
  
  Future<String> getImageUrl(ImageType imageType) async {
    Reference ref = storage.ref().child('$id-$imageType.jpg');

    return await ref.getDownloadURL();
  }
  
  Future<List<String>> getImagesInOrder() async {
    List<String> imagesUrl = [];

    for (ImageType imagetype in ImageType.values) {
      imagesUrl.add(await getImageUrl(imagetype));
    }

    return imagesUrl;
  }

  String getFormattedCoinsInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(sumInCents / 100);
  }
}

class AnalyzedItem {
  final String id;
  final int cents;
  final int confidence;

  const AnalyzedItem(this.id, this.cents, this.confidence);

  AnalyzedItem.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      cents = json['cents'],
      confidence = json['confidence'];

  Future<String> getImageUrl() async {
    Reference ref = storage.ref().child('$id.jpg');

    return await ref.getDownloadURL();
  }

  String getFormattedCoinInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(cents / 100);
  }
}