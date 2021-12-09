import 'dart:io';
import 'package:combien_g/pages/full_image.dart';
import 'package:combien_g/utils/color_utils.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  void sendToServerForPrediction()  {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorUtils.blue,
          title: const Text('Analyser'),
        ),
        body: ListView(padding: EdgeInsets.all(12), children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(scrollDirection: Axis.horizontal,children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return FullImage(imagePath: imagePath);
                      }));
                    },
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(File(imagePath)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Center(child: Text('Les photos traitées vont appaîtres ici', style: FontUtils.content))
                ])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: ColorUtils.blue,
                minimumSize: Size(double.infinity, 36),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                )),
            onPressed: sendToServerForPrediction,
            child: const Text("Démarrer"),
          ),
        ]));
  }
}
