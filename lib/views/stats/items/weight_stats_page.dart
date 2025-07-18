import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'single_stat_page.dart';

class WeightStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SingleStatPage(type: '体重', color: Colors.green);
}
