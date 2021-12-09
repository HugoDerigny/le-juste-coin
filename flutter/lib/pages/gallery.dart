import 'package:combien_g/components/gallery_item.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

class Gallery extends StatelessWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        children: [
          Text('Gallerie', style: FontUtils.title),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.only(top: 16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
                GalleryItem(),
              ],
            ),
          )
        ]
      ),
    );
  }
}
