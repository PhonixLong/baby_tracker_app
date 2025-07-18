import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'items/feeding_stats_page.dart';
import 'items/weight_stats_page.dart';
import 'items/height_stats_page.dart';
import 'items/head_stats_page.dart';

// 主统计入口页面
class StatsPage extends StatelessWidget {
  final List<_StatEntry> entries = [
    _StatEntry('喂养', Icons.local_drink, Colors.blue, FeedingStatsPage()),
    _StatEntry('体重', Icons.monitor_weight, Colors.green, WeightStatsPage()),
    _StatEntry('身高', Icons.height, Colors.blue, HeightStatsPage()),
    _StatEntry('头围', Icons.circle, Colors.deepPurple, HeadStatsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('统计', style: TextStyle(fontSize: 20.sp)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
        itemCount: entries.length,
        separatorBuilder: (_, __) => SizedBox(height: 24.h),
        itemBuilder: (context, i) {
          final entry = entries[i];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ListTile(
              leading: Icon(entry.icon, size: 40.w, color: entry.color),
              title: Text(
                entry.title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: entry.color,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20.w,
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => entry.detailPage));
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatEntry {
  final String title;
  final IconData icon;
  final Color color;
  final Widget detailPage;
  _StatEntry(this.title, this.icon, this.color, this.detailPage);
}

// 删除WeightStatsPage、HeightStatsPage、HeadStatsPage、FeedingStatsPage和_SingleStatPage的实现，全部迁移到items目录下
