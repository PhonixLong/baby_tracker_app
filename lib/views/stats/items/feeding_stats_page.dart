import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:baby_tracker_app/controllers/items/feeding_stats_controller.dart';

// 确保controller注入
final FeedingStatsController controller = Get.put(FeedingStatsController());

class FeedingStatsPage extends GetView<FeedingStatsController> {
  const FeedingStatsPage({Key? key}) : super(key: key);

  Map<String, List<Map<dynamic, dynamic>>> _groupByDate(List records) {
    final map = <String, List<Map<dynamic, dynamic>>>{};
    for (final r in records) {
      final date = (r['date'] ?? '').toString().substring(0, 10);
      map.putIfAbsent(date, () => []).add(r as Map<dynamic, dynamic>);
    }
    return map;
  }

  Map<String, dynamic> _calcDayStats(List<Map<dynamic, dynamic>> dayRecords) {
    double totalMl = 0;
    double totalMin = 0;
    int count = dayRecords.length;
    double breastMl = 0;
    double formulaMl = 0;
    double breastMin = 0;
    double formulaMin = 0;
    int breastCount = 0;
    int formulaCount = 0;
    int totalDuration = 0;
    for (final r in dayRecords) {
      final value = (r['value'] ?? 0).toDouble();
      final unit = r['unit'] ?? '';
      final type = r['type'] ?? '';
      if (unit == 'ml') {
        totalMl += value;
        if (type.toString().contains('母乳')) {
          breastMl += value;
          breastCount++;
        } else if (type.toString().contains('配方奶')) {
          formulaMl += value;
          formulaCount++;
        }
      } else if (unit == 'min') {
        totalMin += value;
        if (type.toString().contains('母乳')) {
          breastMin += value;
        } else if (type.toString().contains('配方奶')) {
          formulaMin += value;
        }
      }
      if (r['duration'] != null) {
        totalDuration += (r['duration'] as num).toInt();
      }
    }
    return {
      'totalMl': totalMl,
      'totalMin': totalMin,
      'count': count,
      'totalDuration': totalDuration,
      'breastMl': breastMl,
      'formulaMl': formulaMl,
      'breastMin': breastMin,
      'formulaMin': formulaMin,
      'breastCount': breastCount,
      'formulaCount': formulaCount,
    };
  }

  Map<String, dynamic> _calcPeriodStats(
    List<Map<dynamic, dynamic>> records,
    DateTime start,
    DateTime end,
  ) {
    double totalMl = 0, breastMl = 0, formulaMl = 0;
    int count = 0, breastCount = 0, formulaCount = 0, totalDuration = 0;
    for (final r in records) {
      final date = DateTime.tryParse(r['date'] ?? '') ?? DateTime(2000);
      if (date.isBefore(start) || date.isAfter(end)) continue;
      final value = (r['value'] ?? 0).toDouble();
      final unit = r['unit'] ?? '';
      final type = r['type'] ?? '';
      if (unit == 'ml') {
        totalMl += value;
        if (type.toString().contains('母乳')) {
          breastMl += value;
          breastCount++;
        } else if (type.toString().contains('配方奶')) {
          formulaMl += value;
          formulaCount++;
        }
      }
      if (r['duration'] != null) {
        totalDuration += (r['duration'] as num).toInt();
      }
      count++;
    }
    return {
      'totalMl': totalMl,
      'breastMl': breastMl,
      'formulaMl': formulaMl,
      'count': count,
      'breastCount': breastCount,
      'formulaCount': formulaCount,
      'totalDuration': totalDuration,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('喂养统计', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return Center(
            child: Text('暂无喂养记录', style: TextStyle(fontSize: 16.sp)),
          );
        }
        final grouped = controller.grouped;
        final sortedDates = controller.sortedDates;
        final weekStats = controller.weekStats;
        final monthStats = controller.monthStats;
        final trend = controller.trend;
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // 汇总卡片
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        children: [
                          Text(
                            '本周总量',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${weekStats['totalMl'].toStringAsFixed(1)} ml',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '母乳: ${weekStats['breastMl'].toStringAsFixed(1)} 配方: ${weekStats['formulaMl'].toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        children: [
                          Text(
                            '本月总量',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${monthStats['totalMl'].toStringAsFixed(1)} ml',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '母乳: ${monthStats['breastMl'].toStringAsFixed(1)} 配方: ${monthStats['formulaMl'].toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // 近7天趋势叠加柱状图
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '近7天喂养量趋势',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 200.h,
                      child: BarChart(
                        BarChartData(
                          barGroups: List.generate(trend.length, (i) {
                            final breast = (trend[i]['breastMl'] as double);
                            final formula = (trend[i]['formulaMl'] as double);
                            return BarChartGroupData(
                              x: i,
                              barsSpace: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: breast + formula,
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                      0,
                                      breast,
                                      Colors.pink,
                                    ),
                                    BarChartRodStackItem(
                                      breast,
                                      breast + formula,
                                      Colors.blue,
                                    ),
                                  ],
                                  width: 18.w,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ],
                            );
                          }),
                          groupsSpace: 18.w,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36.w,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40.w,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= trend.length)
                                    return Container();
                                  final d = trend[idx]['date'] as String;
                                  return Padding(
                                    padding: EdgeInsets.only(top: 6.h),
                                    child: Text(
                                      d.substring(5),
                                      style: TextStyle(fontSize: 11.sp),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          maxY:
                              (trend
                                          .map(
                                            (e) =>
                                                (e['breastMl'] as double) +
                                                (e['formulaMl'] as double),
                                          )
                                          .fold(0.0, (a, b) => a > b ? a : b) *
                                      1.2)
                                  .clamp(10, 9999),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Container(width: 16.w, height: 6.h, color: Colors.pink),
                        SizedBox(width: 4.w),
                        Text('母乳', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 12.w),
                        Container(width: 16.w, height: 6.h, color: Colors.blue),
                        SizedBox(width: 4.w),
                        Text('配方奶', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // 每日分组统计
            ...sortedDates.map((date) {
              final dayRecords = (grouped[date] ?? [])
                  .cast<Map<dynamic, dynamic>>();
              final stats = controller.calcDayStats(dayRecords);
              return GestureDetector(
                onTap: () async {
                  await Get.to(
                    () => FeedingDayDetailPage(date: date, records: dayRecords),
                  );
                  controller.loadRecords();
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20.w,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '共${stats['count']}次',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text('母乳: ', style: TextStyle(fontSize: 14.sp)),
                            Text(
                              '${stats['breastMl'].toStringAsFixed(1)} ml',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.pink,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '(${stats['breastCount']}次)',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.pink[200],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text('配方奶: ', style: TextStyle(fontSize: 14.sp)),
                            Text(
                              '${stats['formulaMl'].toStringAsFixed(1)} ml',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '(${stats['formulaCount']}次)',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.blue[200],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text('总量: ', style: TextStyle(fontSize: 14.sp)),
                            Text(
                              '${stats['totalMl'].toStringAsFixed(1)} ml',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text('总时长: ', style: TextStyle(fontSize: 14.sp)),
                            Text(
                              '${(stats['totalDuration'] / 60).toStringAsFixed(1)} min',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Divider(),
                        ...dayRecords.map((r) {
                          final type = r['type'] ?? '';
                          final value = r['value'] ?? '';
                          final unit = r['unit'] ?? '';
                          final duration = r['duration'];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_drink,
                                  color: Colors.blue,
                                  size: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '$type',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '$value $unit',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                if (duration != null) ...[
                                  SizedBox(width: 8.w),
                                  Text(
                                    '耗时: ${(duration / 60).toStringAsFixed(1)} min',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}

class FeedingDayDetailPage extends StatefulWidget {
  final String date;
  final List<Map<dynamic, dynamic>> records;
  const FeedingDayDetailPage({
    Key? key,
    required this.date,
    required this.records,
  }) : super(key: key);
  @override
  State<FeedingDayDetailPage> createState() => _FeedingDayDetailPageState();
}

class _FeedingDayDetailPageState extends State<FeedingDayDetailPage> {
  late List<Map<dynamic, dynamic>> _records;
  @override
  void initState() {
    super.initState();
    _records = List<Map<dynamic, dynamic>>.from(widget.records);
  }

  Future<void> _editRecord(int idx) async {
    final r = _records[idx];
    final valueController = TextEditingController(
      text: r['value']?.toString() ?? '',
    );
    final type = r['type'] ?? '';
    final unit = r['unit'] ?? '';
    bool changed = false;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: (1.sw - 0.8.sw) / 2),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.blue, size: 24.w),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                '编辑记录',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0.8.sw, maxHeight: 0.8.sh),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型: $type', style: TextStyle(fontSize: 15.sp)),
                SizedBox(height: 10.h),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '数值${unit.isNotEmpty ? '（$unit）' : ''}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                  onChanged: (_) => changed = true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('取消', style: TextStyle(fontSize: 16.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(valueController.text);
              if (value == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('请输入有效的数值')));
                return;
              }
              final box = await Hive.openBox('feedingRecords');
              final key = box.keys.elementAt(box.values.toList().indexOf(r));
              await box.put(key, {...r, 'value': value});
              setState(() => _records[idx]['value'] = value);
              Navigator.of(ctx).pop();
            },
            child: Text('保存', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord(int idx) async {
    final r = _records[idx];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除该条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final box = await Hive.openBox('feedingRecords');
      final key = box.keys.elementAt(box.values.toList().indexOf(r));
      await box.delete(key);
      setState(() => _records.removeAt(idx));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 喂养明细', style: TextStyle(fontSize: 18.sp)),
      ),
      body: _records.isEmpty
          ? Center(
              child: Text('暂无记录', style: TextStyle(fontSize: 16.sp)),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: _records.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, i) {
                final r = _records[i];
                final type = r['type'] ?? '';
                final value = r['value'] ?? '';
                final unit = r['unit'] ?? '';
                final duration = r['duration'];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_drink, color: Colors.blue, size: 22.w),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$type',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '$value $unit',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              if (duration != null)
                                Text(
                                  '耗时: ${(duration / 60).toStringAsFixed(1)} min',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 22.w,
                          ),
                          onPressed: () => _editRecord(i),
                          tooltip: '编辑',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22.w,
                          ),
                          onPressed: () => _deleteRecord(i),
                          tooltip: '删除',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
