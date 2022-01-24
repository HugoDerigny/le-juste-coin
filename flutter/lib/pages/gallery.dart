import 'package:le_juste_coin/utils/color_utils.dart';
import '../components/gallery_item.dart';
import '../models/analyze.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

/// gallerie qui liste toutes les analyses
class Gallery extends StatefulWidget {
  final Function setAnalyzes;
  final Future<List<Analyze>> analyzes;

  /// Tous les filtres avec un label pour l'utilisateur et la méthode
  /// de tri qui sera directement utilisée
  static final filters = {
    "DATE_DESC": {
      "label": "Le plus récent",
      "method": (Analyze a, Analyze b) {
        return a.createdAt.isBefore(b.createdAt) ? 1 : -1;
      }
    },
    "DATE_ASC": {
      "label": "Le plus ancien",
      "method": (Analyze a, Analyze b) {
        return a.createdAt.isAfter(b.createdAt) ? 1 : -1;
      }
    },
    "SUM_DESC": {
      "label": "Le + cher",
      "method": (Analyze a, Analyze b) {
        return b.sumInCents - a.sumInCents;
      }
    },
    "SUM_ASC": {
      "label": "Le - cher",
      "method": (Analyze a, Analyze b) {
        return a.sumInCents - b.sumInCents;
      }
    },
    "CONFIDENCE_DESC": {
      "label": "Le + confiant",
      "method": (Analyze a, Analyze b) {
        return b.averageConfidence - a.averageConfidence;
      }
    },
    "CONFIDENCE_ASC": {
      "label": "Le - confiant",
      "method": (Analyze a, Analyze b) {
        return a.averageConfidence - b.averageConfidence;
      }
    }
  };

  const Gallery({Key? key, required this.setAnalyzes, required this.analyzes})
      : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  /// on trie par défaut sur les analyses les plus récentes
  String _activeFilter = "DATE_DESC";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gallerie', style: FontUtils.title),
            Row(
              children: [
                Text('Trier par', style: FontUtils.content),
                const SizedBox(width: 8),
                DropdownButton(
                  value: _activeFilter,
                  items: [
                    ...Gallery.filters.entries.map((
                        MapEntry<String, Map<String, dynamic>> e) =>
                        DropdownMenuItem(
                            child: Text(e.value['label'].toString()),
                            value: e.key))
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _activeFilter = value!;
                    });
                  },
                )
              ],
            ),
            FutureBuilder<List<Analyze>>(
              future: widget.analyzes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isNotEmpty) {

                    snapshot.data!.sort((a, b) {
                      Map<String, dynamic> filter = Gallery.filters[_activeFilter]!;

                      return Function.apply(filter['method'], [a, b]);
                    });

                    return Expanded(
                        child: RefreshIndicator(
                            child: GridView.count(
                              padding: const EdgeInsets.only(top: 16),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              children: [
                                ...snapshot.data!
                                    .map((analyze) =>
                                    GalleryItem(
                                        analyze: analyze,
                                        refreshAnalyses: widget.setAnalyzes))
                                    .toList()
                              ],
                            ),
                            onRefresh: () async {
                              widget.setAnalyzes();
                            }));
                  } else {
                    return Container(
                        margin: const EdgeInsets.only(top: 32),
                        child: Center(
                            child: Column(children: [
                              Text('Prenez une photo pour faire une analyse.',
                                  style: FontUtils.content),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  widget.setAnalyzes();
                                },
                                child: const Text('Rafraîchir'),
                                style: ElevatedButton.styleFrom(
                                    primary: ColorUtils.gold,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    )),
                              )
                            ])));
                  }
                } else if (snapshot.hasError) {
                  return Column(children: [
                    const SizedBox(height: 32),
                    Text('Une erreur est survenue: ${snapshot.error}',
                        style: FontUtils.contentDanger),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        widget.setAnalyzes();
                      },
                      child: const Text('Rafraîchir'),
                      style: ElevatedButton.styleFrom(
                          primary: ColorUtils.danger,
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                    )
                  ]);
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator(color: ColorUtils.blue);
              },
            )
          ]),
    );
  }
}
