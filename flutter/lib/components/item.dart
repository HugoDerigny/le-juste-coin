import 'package:combien_g/components/tag.dart';
import 'package:combien_g/main.dart';
import 'package:combien_g/utils/color_utils.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  const Item({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.all(16),
        child: ListView(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network('https://cdn.futura-sciences.com/buildsv6/images/wide1920/c/8/d/c8d3c332c2_50162761_pieces-euros-pixarno-adobe-stock.jpg',
                fit: BoxFit.fill),
          ),
          SizedBox(height: 8),
          Text('11/11/1111 - #1234', style: FontUtils.content),
          SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('12€', style: FontUtils.title), Tag(content: '66%', color: ColorUtils.success)]),
          SizedBox(height: 24),
          Text('Détails des analyses', style: FontUtils.header),
          SizedBox(height: 8),
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: ColorUtils.gray), borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        'https://bulma.io/images/placeholders/128x128.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('1€', style: FontUtils.header)
                  ]),
                  Tag(content: '66%', color: ColorUtils.success)
                ],
              )),
          SizedBox(height: 4),
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: ColorUtils.gray), borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        'https://bulma.io/images/placeholders/128x128.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('2€', style: FontUtils.header)
                  ]),
                  Tag(content: '32%', color: ColorUtils.warning)
                ],
              )),
          SizedBox(height: 4),
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: ColorUtils.gray), borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        'https://bulma.io/images/placeholders/128x128.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('2€', style: FontUtils.header)
                  ]),
                  Tag(content: '16%', color: ColorUtils.danger)
                ],
              )),
          SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: ColorUtils.blue,
                minimumSize: Size(double.infinity, 36),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                )),
            onPressed: () {},
            child: const Text("Réeffectuer l'analyse"),
          ),
        ]));
  }
}
