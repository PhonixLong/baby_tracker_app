import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 这里只保留成长记录相关内容，统计相关已迁移到stats_home_page.dart

class GrowthRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这里可以放成长记录的添加/管理入口或提示
    return Scaffold(
      appBar: AppBar(
        title: Text('成长记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Center(
        child: Text(
          '成长记录功能已迁移，或在此添加成长记录管理入口',
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
}
