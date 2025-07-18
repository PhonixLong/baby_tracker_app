import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicalRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('医疗记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Center(
        child: Text('医疗记录内容', style: TextStyle(fontSize: 16.sp)),
      ), // TODO: 替换为原医疗记录内容
    );
  }
}
