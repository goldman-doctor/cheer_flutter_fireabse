import 'package:flutter/material.dart';
import 'package:cheer/themes/light_color.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  const TitleText({
    super.key,
    this.color = LightColor.subTitleTextColor,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w800,
    required this.text,
    this.textAlign = TextAlign.center,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.mulish(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        decoration: TextDecoration.none,
      ),
    );
  }
}
