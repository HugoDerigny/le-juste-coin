import 'dart:io';

import 'package:flutter/material.dart';
import 'package:le_juste_coin/utils/color_utils.dart';

class FullImage extends StatelessWidget {
  const FullImage({Key? key, this.title = '', required this.imagePath}) : super(key: key);

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    bool _isUrl = Uri.parse(imagePath).isAbsolute;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorUtils.blue,
        title: Text(title),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: _isUrl ? Image.network(imagePath) : Image.file(File(imagePath))
          ),
        ),
      ),
    );
  }
}