import 'package:combien_g/utils/color_utils.dart';
import 'package:flutter/material.dart';

class FontUtils {
  static TextStyle title = const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static TextStyle header = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle content = TextStyle(fontSize: 12, color: ColorUtils.darkGray);

  static TextStyle tag = TextStyle(fontSize: 12, color: ColorUtils.white, fontWeight: FontWeight.bold);

  static TextStyle contentSuccess = TextStyle(fontSize: 12, color: ColorUtils.success, fontWeight: FontWeight.bold);
  static TextStyle contentWarning = TextStyle(fontSize: 12, color: ColorUtils.warning, fontWeight: FontWeight.bold);
  static TextStyle contentDanger = TextStyle(fontSize: 12, color: ColorUtils.danger, fontWeight: FontWeight.bold);
}