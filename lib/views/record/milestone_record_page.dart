import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('里程记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Center(
        child: Text('里程记录内容', style: TextStyle(fontSize: 16.sp)),
      ), // TODO: 替换为原里程记录内容
    );
  }
}
