import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cheer/themes/theme.dart';
import 'package:cheer/widgets/title_text.dart';

class Usercard extends StatefulWidget {
  final String username;
  final String? email;
  final String avatarText;
  final VoidCallback onTap;
  final Color avatarBackgroundColor;
  final String? avatarUrl;
  final double avatarSize;
  final double fontSize;
  final bool isOnline;
  final int unreadCount;
  const Usercard({
    super.key,
    this.email,
    required this.username,
    required this.avatarText,
    required this.onTap,
    required this.avatarBackgroundColor,
    this.avatarUrl,
    required this.avatarSize,
    required this.fontSize,
    required this.isOnline,
    required this.unreadCount,
  });

  @override
  State<Usercard> createState() => _UserCardState();
}

class _UserCardState extends State<Usercard> {
  bool isBase64Image(String str) {
    return str.startsWith('data:image/') ||
        (str.length > 100 && !str.startsWith('http'));
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      if (isBase64Image(widget.avatarUrl!)) {
        String base64Str = widget.avatarUrl!;
        if (base64Str.startsWith('data:image/')) {
          final base64Index = base64Str.indexOf('base64,');
          if (base64Index != -1) {
            base64Str = base64Str.substring(base64Index + 7);
          }
        }
        final decodedBytes = base64Decode(base64Str);
        avatarWidget = CircleAvatar(
          radius: widget.avatarSize,
          backgroundImage: MemoryImage(decodedBytes),
        );
      } else {
        avatarWidget = CircleAvatar(
          radius: widget.avatarSize,
          backgroundImage: NetworkImage(widget.avatarUrl!),
        );
      }
    } else {
      avatarWidget = CircleAvatar(
        radius: widget.avatarSize,
        backgroundColor: Colors.grey,
        child: TitleText(
          text: widget.avatarText,
          color: Colors.white,
          fontSize: widget.fontSize,
        ),
      );
    }

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: AppTheme.fullWidth(context) * .9,
        height: 80,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                avatarWidget,
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.only(right: 2),
                    width: widget.avatarSize / 3,
                    height: widget.avatarSize / 3,
                    decoration: BoxDecoration(
                      color: widget.isOnline ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                if (widget.unreadCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                      child: Center(
                        child: Text(
                          widget.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            TitleText(
              text: widget.username,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
