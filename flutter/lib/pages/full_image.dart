import 'dart:io';
import 'package:flutter/material.dart';
import 'package:le_juste_coin/utils/color_utils.dart';

/// affiche une image en grand
class FullImage extends StatelessWidget {
  const FullImage({Key? key, this.title = '', required this.imagePath})
      : super(key: key);

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    /// affichage différent s'il s'agit d'une image locale ou d'une image avec un
    /// lien
    bool _isUrl = Uri.parse(imagePath).isAbsolute;

    return Scaffold(
      backgroundColor: ColorUtils.pureBlack,
      appBar: AppBar(
        backgroundColor: ColorUtils.pureBlack,
        title: Text(title, style: TextStyle(color: ColorUtils.white)),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
            child: InteractiveViewer(
                panEnabled: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.25,
                maxScale: 2.5,
                child: _isUrl
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        alignment: Alignment.center,
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        alignment: Alignment.center,
                      ))),
      ),
    );
  }
}
