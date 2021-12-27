import '../components/tag.dart';
import '../models/analyze.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  final Analyze analyze;

  const Item({Key? key, required this.analyze}) : super(key: key);

  Color _getColorOnConfidence(int confidence) {
    Color ok = ColorUtils.success;
    Color average = ColorUtils.warning;
    Color bad = ColorUtils.danger;

    return confidence > 80 ? ok : confidence > 40 ? average : bad;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FutureBuilder(
              future: analyze.getImageUrl(ImageType.ORIGINAL),
              builder: (BuildContext context, AsyncSnapshot<String> image) {
                if (image.hasData) {
                  return Image.network(image.data!, fit: BoxFit.fill) ;  // image is ready
                } else {
                  return const CircularProgressIndicator();  // placeholder
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Text('${analyze.id} - ${analyze.getFullDateFormatted()}', style: FontUtils.content),
          const SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(analyze.getFormattedCoinsInEuros(), style: FontUtils.title), Tag(content: '${analyze.averageConfidence}%', color: _getColorOnConfidence(analyze.averageConfidence))]),
          const SizedBox(height: 24),
          Text('Détails des analyses', style: FontUtils.header),
          ...analyze.items.map((item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: FutureBuilder(
                      future: item.getImageUrl(),
                      builder: (BuildContext context, AsyncSnapshot<String> image) {
                        if (image.hasData) {
                          return Image.network(image.data!, fit: BoxFit.fill, width: 48, height: 48) ;  // image is ready
                        } else {
                          return const CircularProgressIndicator();  // placeholder
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.getFormattedCoinInEuros(), style: FontUtils.header)
                ]),
                Tag(content: '${item.confidence}%', color: _getColorOnConfidence(item.confidence))
              ],
            )).toList(),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: ColorUtils.blue,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
            onPressed: () {},
            child: const Text("Réeffectuer l'analyse"),
          ),
        ])
    );
  }
}
