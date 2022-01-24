import 'package:le_juste_coin/components/tag.dart';
import 'package:le_juste_coin/utils/color_utils.dart';
import '../components/item.dart';
import '../models/analyze.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

/// Carte d'une analyse affichée dans la gallerie.
/// Il est possible de taper sur celle-ci pour afficher l'analyse dans une fenêtre modale du bas.
class GalleryItem extends StatelessWidget {
  final Function refreshAnalyses;
  final Analyze analyze;

  const GalleryItem({Key? key, required this.analyze, required this.refreshAnalyses}) : super(key: key);

  /// Affiche l'analyse lors d'un tap sur la carte
  void openItem(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
        ),
        builder: (context) {
          return Item(analyze: analyze, refreshAnalyses: refreshAnalyses);
        });
  }

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openItem(context);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: FutureBuilder(
            future: analyze.getImageUrl(ImageType.original),
            builder: (BuildContext context, AsyncSnapshot<String> image) {
              if (image.hasData) {
                return Image.network(image.data!, fit: BoxFit.cover, height: 128, width: double.infinity,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(height: 128, color:ColorUtils.gray, width: double.infinity, child: Center(child: CircularProgressIndicator(color:  ColorUtils.blue, value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)));
                }); // image is ready
              } else {
                return Container(height: 128, color:ColorUtils.gray, width: double.infinity, child: Center(child: CircularProgressIndicator(color:  ColorUtils.blue)));
              }
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(analyze.getFormattedCoinsInEuros(), style: FontUtils.header),
            Tag(content: '${analyze.averageConfidence}%', color: _getColorOnConfidence(analyze.averageConfidence))
          ],
        ),
        const SizedBox(height: 4),
        Text(analyze.getDateFormatted(), style: FontUtils.content),
      ]),
    );
  }
}
