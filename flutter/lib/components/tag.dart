import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

/// Petite étiquette qui prend en paramètre un texte et une couleur de fond
class Tag extends StatelessWidget {
  const Tag({Key? key, required this.content, required this.color}) : super(key: key);

  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Container(
        padding: const EdgeInsets.only(top: 2, bottom: 2, left: 6, right: 6),
        color: color,
        child: Text(content, style: FontUtils.tag),
      )
    );
  }
}
