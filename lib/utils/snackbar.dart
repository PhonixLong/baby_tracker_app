import 'package:flutter/material.dart';

SnackBar buildNiceSnackBar(
  BuildContext context,
  String text, {
  IconData? icon,
  Color? color,
}) {
  final Color mainColor = color ?? Theme.of(context).colorScheme.primary;
  return SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.13),
            ),
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.only(right: 12),
            child: Icon(icon, color: mainColor, size: 22),
          ),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: mainColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    elevation: 8,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    duration: Duration(milliseconds: 1800),
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  );
}
