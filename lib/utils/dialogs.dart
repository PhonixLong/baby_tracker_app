import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<T?> showNiceDialog<T>({
  required BuildContext context,
  Widget? icon,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
  double maxWidth = 0.8,
  double borderRadius = 18,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: (1.sw - maxWidth.sw) / 2),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, SizedBox(width: 8.w)],
          Flexible(child: title),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.sw, maxHeight: 0.8.sh),
        child: SingleChildScrollView(child: content),
      ),
      actions: actions,
    ),
  );
}

Future<T?> showGetDialog<T>({
  required BuildContext context,
  Widget? icon,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
  double maxWidth = 0.8,
  double borderRadius = 18,
}) {
  return Get.dialog<T>(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: (1.sw - maxWidth.sw) / 2),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, SizedBox(width: 8.w)],
          Flexible(child: title),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.sw, maxHeight: 0.8.sh),
        child: SingleChildScrollView(child: content),
      ),
      actions: actions,
    ),
  );
}
