import 'dart:io';

import 'package:flutter/material.dart';

class FullImage extends StatelessWidget {
  const FullImage({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.file(File(imagePath))
          ),
        ),
      ),
    );
  }
}