import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:baby_tracker_app/utils/dialogs.dart';

class SingleStatPage extends StatefulWidget {
  final String type;
  final Color color;
  const SingleStatPage({required this.type, required this.color});
  @override
  State<SingleStatPage> createState() => _SingleStatPageState();
}

class _SingleStatPageState extends State<SingleStatPage> {
  bool showChart = true;
  Future<List<Map<String, dynamic>>> _getRecordsAsc() async {
    final box = await Hive.openBox('growthRecords');
    final List<Map<String, dynamic>> records = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map && value['type'] == widget.type) {
        records.add({...value, '_key': key});
      }
    }
    records.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    return records;
  }

  Future<List<Map<String, dynamic>>> _getRecordsDesc() async {
    final box = await Hive.openBox('growthRecords');
    final List<Map<String, dynamic>> records = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map && value['type'] == widget.type) {
        records.add({...value, '_key': key});
      }
    }
    records.sort(
      (a, b) => (b['date'] as String).compareTo(a['date'] as String),
    );
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type}统计', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButtons(
                  isSelected: [showChart, !showChart],
                  onPressed: (idx) {
                    setState(() {
                      showChart = idx == 0;
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(Icons.show_chart, size: 20.w),
                          Text('图表', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(Icons.list, size: 20.w),
                          Text('列表', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(child: showChart ? _buildChart() : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecordsDesc(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '暂无 ${widget.type} 记录',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }
        final records = snapshot.data!;
        return ListView.separated(
          itemCount: records.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) {
            final r = records[i];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: widget.color,
                        size: 22.w,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${r['value']}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                r['unit'] ?? '',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            r['date'].toString().substring(0, 10),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 22.w,
                          ),
                          onPressed: () {
                            _showEditDialog(r);
                          },
                          tooltip: '编辑',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22.w,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('确认删除'),
                                content: Text('确定要删除该条记录吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text(
                                      '删除',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final box = await Hive.openBox('growthRecords');
                              await box.delete(r['_key']);
                              setState(() {});
                            }
                          },
                          tooltip: '删除',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecordsAsc(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(strokeWidth: 20.w));
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return Center(
            child: Text(
              '暂无${widget.type}记录',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }
        final baseDate =
            DateTime.tryParse(records.first['date'] ?? '') ?? DateTime.now();
        final dateList = records
            .map((r) => DateTime.tryParse(r['date'] ?? '') ?? baseDate)
            .toList();
        final spots = <FlSpot>[];
        for (int i = 0; i < records.length; i++) {
          final value = (records[i]['value'] as num?)?.toDouble() ?? 0;
          final days = dateList[i].difference(baseDate).inDays.toDouble();
          spots.add(FlSpot(days, value));
        }
        final unit = records.first['unit'] ?? '';
        double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
        double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        double range = (maxY - minY).abs();
        double interval = 1;
        if (range > 10) {
          interval = 5;
        } else if (range > 5) {
          interval = 2;
        } else if (range > 2) {
          interval = 1;
        } else if (range > 1) {
          interval = 0.5;
        } else {
          interval = 0.2;
        }
        minY = (minY / interval).floor() * interval;
        maxY = (maxY / interval).ceil() * interval;
        // x轴标签
        List<int> labelIndexes = [];
        if (records.length <= 5) {
          labelIndexes = List.generate(records.length, (i) => i);
        } else {
          labelIndexes = [0];
          int step = (records.length - 1) ~/ 4;
          for (int i = 1; i < 4; i++) {
            int idx = (i * step).clamp(1, records.length - 2);
            if (!labelIndexes.contains(idx)) labelIndexes.add(idx);
          }
          if (!labelIndexes.contains(records.length - 1))
            labelIndexes.add(records.length - 1);
          labelIndexes.sort();
        }
        final labelDays = labelIndexes
            .map((i) => dateList[i].difference(baseDate).inDays.toDouble())
            .toList();
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.symmetric(vertical: 12.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.type}变化',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    Spacer(),
                    if (unit.isNotEmpty)
                      Text(
                        '单位: $unit',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 220.h,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      minX: spots.first.x,
                      maxX: spots.last.x,
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
                            reservedSize: 48.w,
                            getTitlesWidget: (value, meta) {
                              if (!labelDays.contains(value))
                                return Container();
                              int idx = labelDays.indexOf(value);
                              if (idx < 0 || idx >= labelIndexes.length)
                                return Container();
                              final date = dateList[labelIndexes[idx]];
                              return Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  '${date.month}/${date.day}',
                                  style: TextStyle(fontSize: 12.sp),
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
                        horizontalInterval: interval,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: widget.color,
                          barWidth: 3.w,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.3),
                                widget.color.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 3.w,
                                color: widget.color,
                                strokeWidth: 0,
                                strokeColor: widget.color,
                              );
                            },
                          ),
                          isStrokeCapRound: true,
                          shadow: Shadow(
                            color: widget.color.withOpacity(0.25),
                            blurRadius: 8.w,
                            offset: Offset(0, 4.h),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Colors.black87,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final idx = spots.indexWhere(
                                (s) => (s.x - spot.x).abs() < 0.01,
                              );
                              if (idx < 0) return null;
                              final date = dateList[idx];
                              final value = records[idx]['value'];
                              final unit = records[idx]['unit'] ?? '';
                              return LineTooltipItem(
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                                '\n$value $unit',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(Map<String, dynamic> record) async {
    final valueController = TextEditingController(
      text: record['value']?.toString() ?? '',
    );
    DateTime selectedDate =
        DateTime.tryParse(record['date'] ?? '') ?? DateTime.now();
    final unit = record['unit'] ?? '';
    bool changed = false;
    await showNiceDialog(
      context: context,
      icon: Icon(Icons.edit, color: widget.color, size: 24.w),
      title: Text(
        '编辑${widget.type}记录',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数值',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: valueController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '请输入${widget.type}${unit.isNotEmpty ? '（$unit）' : ''}',
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
          SizedBox(height: 16.h),
          Text(
            '日期',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 15.sp),
              ),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                icon: Icon(Icons.edit_calendar, size: 20.sp),
                label: Text('选择日期', style: TextStyle(fontSize: 14.sp)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(Duration(days: 1)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    changed = true;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
            final box = await Hive.openBox('growthRecords');
            await box.put(record['_key'], {
              ...record,
              'value': value,
              'date': selectedDate.toIso8601String(),
            });
            Navigator.of(context).pop();
            setState(() {});
          },
          child: Text('保存', style: TextStyle(fontSize: 16.sp)),
        ),
      ],
      maxWidth: 0.8,
      borderRadius: 18,
    );
  }
}
