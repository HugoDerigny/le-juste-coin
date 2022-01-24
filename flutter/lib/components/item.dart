import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_juste_coin/pages/full_image.dart';
import 'package:http/http.dart' as http;
import '../components/tag.dart';
import '../models/analyze.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final Analyze analyze;
  final Function refreshAnalyses;

  const Item({Key? key, required this.analyze, required this.refreshAnalyses})
      : super(key: key);

  @override
  _ItemState createState() => _ItemState();
}

/// Détail de l'analyse affichée dans la fenêtre modale lorsque l'utilisateur
/// tape sur une carte dans [gallery_item.dart]
class _ItemState extends State<Item> {
  bool _isBeingRemoved = false;

  /// Renvoie une couleur selon l'indice de confiance de l'analyse
  Color _getColorOnConfidence(int confidence) {
    Color ok = ColorUtils.success;
    Color average = ColorUtils.warning;
    Color bad = ColorUtils.danger;

    return confidence > 80
        ? ok
        : confidence > 40
            ? average
            : bad;
  }

  /// Envoie une requête à l'API pour supprimer une analyse.
  /// S'il y a succès alors la fenêtre se ferme.
  /// Sinon un message d'erreur apparaît.
  Future<void> _removeAnalyze(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    String analyzesEndpoint = dotenv.env['API_URL']! + '/analyse';

    setState(() {
      _isBeingRemoved = true;
    });

    final response = await http.delete(Uri.parse(analyzesEndpoint),
        headers: {
          'Authorization': auth.currentUser!.uid,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'analyze_id': widget.analyze.getOriginalId()}));

    setState(() {
      _isBeingRemoved = false;
    });

    widget.refreshAnalyses();

    if (response.statusCode == 204) {
      Navigator.pop(context);
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    Analyze analyze = widget.analyze;

    return Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          FutureBuilder(
            future: analyze.getImageUrl(ImageType.original),
            builder: (BuildContext context, AsyncSnapshot<String> image) {
              if (image.hasData) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return FullImage(
                            title: 'Photo originale', imagePath: image.data!);
                      }));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(image.data!,
                            fit: BoxFit.cover,
                            height: 384, loadingBuilder: (BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              height: 384,
                              color: ColorUtils.gray,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: ColorUtils.blue,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null)));
                        }))); // image is ready
              } else {
                return Container(
                    height: 384,
                    color: ColorUtils.gray,
                    child: Center(
                        child:
                            CircularProgressIndicator(color: ColorUtils.blue)));
              }
            },
          ),
          const SizedBox(height: 4),
          SizedBox(
              height: 96,
              child: FutureBuilder(
                future: analyze.getImagesInOrder(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, String>> images) {
                  if (images.hasData) {
                    return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...images.data!.keys
                              .map((imageType) => Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return FullImage(
                                              title: imageType,
                                              imagePath:
                                                  images.data![imageType]!);
                                        }));
                                      },
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Image.network(
                                              images.data![imageType]!,
                                              fit: BoxFit.cover,
                                              width: 96, loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                                height: 96,
                                                margin:
                                                    const EdgeInsets.only(right: 4),
                                                color: ColorUtils.gray,
                                                width: 96,
                                                child: Center(
                                                    child: CircularProgressIndicator(
                                                        color: ColorUtils.blue,
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null)));
                                          })))))
                              .toList()
                        ]);
                  } else {
                    return ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                  height: 96,
                                  width: 96,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: ColorUtils.gray,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: ColorUtils.blue))));
                        });
                  }
                },
              )),
          const SizedBox(height: 8),
          Text('${analyze.id} - ${analyze.getFullDateFormatted()}',
              style: FontUtils.content),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(analyze.getFormattedCoinsInEuros(), style: FontUtils.title),
            Tag(
                content: '${analyze.averageConfidence}%',
                color: _getColorOnConfidence(analyze.averageConfidence))
          ]),
          const SizedBox(height: 24),
          Text('Détails des analyses', style: FontUtils.header),
          const SizedBox(height: 8),
          ...analyze.items
              .map(
                (AnalyzedItem item) => Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: ColorUtils.gray,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          FutureBuilder(
                            future: item.getImageUrl(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> image) {
                              if (image.hasData) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return FullImage(
                                            title: item.id,
                                            imagePath: image.data!);
                                      }));
                                    },
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.network(image.data!,
                                            fit: BoxFit.fill,
                                            width: 48,
                                            height: 48))); // image is ready
                              } else {
                                return const CircularProgressIndicator(); // placeholder
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(item.getFormattedCoinInEuros(),
                              style: FontUtils.header)
                        ]),
                        Tag(
                            content: '${item.confidence}%',
                            color: _getColorOnConfidence(item.confidence))
                      ],
                    )),
              )
              .toList(),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: ColorUtils.blue,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
            onPressed: () {},
            child: const Text("Refaire l'analyse"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: ColorUtils.danger,
                textStyle: FontUtils.header,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
            onPressed: _isBeingRemoved ? null : () async {
              _removeAnalyze(context);
            },
            child: Text(_isBeingRemoved ? "Suppression..." : "Supprimer", style: TextStyle(color: ColorUtils.white)),
          ),
        ]));
  }
}
