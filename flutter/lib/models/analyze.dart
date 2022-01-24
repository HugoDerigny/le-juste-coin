import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

/// Enumeration des différents types d'images traitées
enum ImageType {
  original,
  blurred,
  dilated,
  eroded,
  canny,
  circles
}

/// Enumeration des différentes valeurs de pièces
enum CoinValue { twoEuros, oneEuro, fiftyCent, twentyCent, tenCent, fiveCent }

/// Instance du Storage de Firebase
var storage = FirebaseStorage.instance;

/// Notre modèle le plus important, celui des analyses. Il contient toutes les
/// informations nécessaires à l'affichage.
class Analyze {
  /// unique ID qui permet d'effectuer des actions avec (attention il y a le # avec).
  final String id;
  /// date à laquelle l'analyse a été faite
  final DateTime createdAt;
  /// somme totale en centimes
  final int sumInCents;
  /// confiance de l'analyse (fait la moyenne de la confiance pour chaque détail)
  final int averageConfidence;
  /// détail de l'anayse
  final List<AnalyzedItem> items;

  /// map entre le type d'image et le nom utilisé pour la stocker dans firebase
  static final images = {
    ImageType.original: 'original',
    ImageType.blurred: 'blur',
    ImageType.dilated: 'dilate',
    ImageType.eroded: 'erode',
    ImageType.canny: 'canny',
    ImageType.circles: 'circles',
  };

  Analyze(this.id, this.createdAt, this.sumInCents, this.averageConfidence,
      this.items);

  Analyze.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      createdAt = DateTime.parse(json['created_at']),
      sumInCents = json['sum_of_coins'],
      averageConfidence = json['average_confidence'],
      items = List<AnalyzedItem>.from(json['items'].map((item) => AnalyzedItem.fromJson(item)));

  /// renvoie la date de création au format français
  String getDateFormatted() {
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    return formatter.format(createdAt);
  }

  /// renvoie la date de création au format français avec l'heure
  String getFullDateFormatted() {
    DateFormat formatter = DateFormat('dd/MM/yyyy à hh:mm');

    return formatter.format(createdAt);
  }

  /// appelle le storage de firebase pour récupérer le lien d'une image selon
  /// son nom.
  /// on utilise l'id de l'analyse et le type d'image qui est passé en paramètre
  Future<String> getImageUrl(ImageType imageType) async {
    Reference ref = storage.ref().child('$id-${images[imageType]}.jpg');
  
    return await ref.getDownloadURL();
  }

  /// renvoie une liste de avec les liens de toutes les images dans l'ordre par
  /// lesquelles elles ont été traitées. il s'agit de l'ordre définit par l'énumération
  Future<Map<String, String>> getImagesInOrder() async {
    Map<String, String> imagesUrl = {};

    for (ImageType imagetype in ImageType.values) {
      imagesUrl[images[imagetype]!] = await getImageUrl(imagetype);
    }

    return imagesUrl;
  }

  /// renvoie la somme de l'analyse formattée en euro
  String getFormattedCoinsInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(sumInCents / 100);
  }

  /// Transforme l'ID formaté #123456 en ID brut 123456.
  String getOriginalId() {
    return id.substring(1);
  }
}


/// Détail d'une analyse
class AnalyzedItem {
  /// ID complet (ex: #ABCDEF-3)
  final String id;
  /// somme en centime de la pièce
  final int cents;
  /// indice de confiance
  final int confidence;

  const AnalyzedItem(this.id, this.cents, this.confidence);

  AnalyzedItem.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      cents = json['coin'],
      confidence = json['confidence'];

  /// renvoie le lien vers l'image
  Future<String> getImageUrl() async {
    Reference ref = storage.ref().child('$id.jpg');

    return await ref.getDownloadURL();
  }

  /// renvoie la somme formatée en euro
  String getFormattedCoinInEuros() {
    NumberFormat formatter = NumberFormat("#,##0.00€", "fr_FR");

    return formatter.format(cents / 100);
  }
}