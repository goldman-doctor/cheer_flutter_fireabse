import 'package:flutter/material.dart';
import 'package:cheer/themes/light_color.dart';
import 'package:cheer/themes/theme.dart';
import 'package:cheer/widgets/title_text.dart';

class Customtextbutton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color backgroundcolor;
  final Color? bordercolor;
  final Widget? leading;
  const Customtextbutton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = LightColor.subTitleTextColor,
    this.fontSize = 18,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.w800,
    this.backgroundcolor = Colors.deepOrange,
    this.bordercolor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2),
        width: AppTheme.fullWidth(context) * 0.85,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundcolor,
          border: bordercolor != null ? Border.all(color: bordercolor!) : null,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 8)],
            TitleText(
              text: text,
              fontSize: fontSize,
              color: color,
              textAlign: textAlign,
            ),
          ],
        ),
      ),
    );
  }
}
