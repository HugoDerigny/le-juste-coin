import 'package:combien_g/utils/color_utils.dart';
import 'package:combien_g/utils/font_utils.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag({Key? key, required this.content, required this.color}) : super(key: key);

  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            padding: EdgeInsets.only(top: 2, bottom: 2, left: 6, right: 6),
            color: color,
            child: Text(content, style: FontUtils.tag),
          )
        )// T;
    );
  }
}
