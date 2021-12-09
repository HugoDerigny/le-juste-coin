import 'package:combien_g/components/item.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  const GalleryItem({Key? key}) : super(key: key);

  void openItem(BuildContext context) {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        // backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
        ),
        builder: (context) {
          return Item();
        });
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
          child: Image.network('https://cdn.futura-sciences.com/buildsv6/images/wide1920/c/8/d/c8d3c332c2_50162761_pieces-euros-pixarno-adobe-stock.jpg',
              fit: BoxFit.fill),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12€', style: FontUtils.header),
            Text('66%', style: FontUtils.contentSuccess),
          ],
        ),
        SizedBox(height: 4),
        Text('11/11/1111', style: FontUtils.content),
      ]),
    );
  }
}
