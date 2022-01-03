import 'package:le_juste_coin/utils/color_utils.dart';
import '../components/gallery_item.dart';
import '../models/analyze.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  final Function setAnalyzes;
  final Future<List<Analyze>> analyzes;

  Gallery({Key? key, required this.setAnalyzes, required this.analyzes}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {

  @override
  Widget build(BuildContext context) {
    print(widget.analyzes);
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('Gallerie', style: FontUtils.title),
        FutureBuilder<List<Analyze>>(
          future: widget.analyzes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length > 0) {
                return Expanded(
                    child: RefreshIndicator(
                        child: GridView.count(
                          padding: EdgeInsets.only(top: 16),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2,
                          children: [...snapshot.data!.map((analyze) => GalleryItem(analyze: analyze, refreshAnalyses: widget.setAnalyzes)).toList()],
                        ),
                        onRefresh: () async {
                          widget.setAnalyzes();
                        }));
              } else {
                return Container(
                    margin: EdgeInsets.only(top: 32),
                    child: Center(
                        child: Column(children: [
                  Text('Prenez une photo pour faire une analyse.', style: FontUtils.content),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () { widget.setAnalyzes(); },
                    child: Text('Rafraîchir'),
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
                SizedBox(height: 32),
                Text('Une erreur est survenue: ${snapshot.error}', style: FontUtils.contentDanger),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () { widget.setAnalyzes(); },
                  child: Text('Rafraîchir'),
                  style: ElevatedButton.styleFrom(
                      primary: ColorUtils.danger,
                      minimumSize: Size(double.infinity, 36),
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
