import '../components/item.dart';
import '../models/analyze.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  final Analyze analyze;

  const GalleryItem({ Key? key, required this.analyze}) : super(key: key);

  void openItem(BuildContext context) {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        // backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
        ),
        builder: (context) {
          return Item(analyze: analyze);
        });
  }

  TextStyle _getColorOnConfidence(int confidence) {
    TextStyle ok = FontUtils.contentSuccess;
    TextStyle average = FontUtils.contentWarning;
    TextStyle bad = FontUtils.contentDanger;

    return confidence > 80 ? ok : confidence > 40 ? average : bad;
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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${analyze.getFormattedCoinsInEuros()}€', style: FontUtils.header),
            Text('${analyze.averageConfidence}%', style: _getColorOnConfidence(analyze.averageConfidence)),
          ],
        ),
        const SizedBox(height: 4),
        Text(analyze.getDateFormatted(), style: FontUtils.content),
      ]),
    );
  }
}
