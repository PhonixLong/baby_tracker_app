import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

// 主统计入口页面
class StatsHomePage extends StatelessWidget {
  final List<_StatEntry> entries = [
    _StatEntry('体重', Icons.monitor_weight, Colors.green, WeightStatsPage()),
    _StatEntry('身高', Icons.height, Colors.blue, HeightStatsPage()),
    _StatEntry('头围', Icons.circle, Colors.deepPurple, HeadStatsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('成长统计')),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        itemCount: entries.length,
        separatorBuilder: (_, __) => SizedBox(height: 24),
        itemBuilder: (context, i) {
          final entry = entries[i];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Icon(entry.icon, size: 40, color: entry.color),
              title: Text(
                entry.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: entry.color,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
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

// 单项详细统计页面（体重/身高/头围）
class WeightStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      _SingleStatPage(type: '体重', color: Colors.green);
}

class HeightStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      _SingleStatPage(type: '身高', color: Colors.blue);
}

class HeadStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      _SingleStatPage(type: '头围', color: Colors.deepPurple);
}

// 复用原有的单项统计内容（图表+列表+编辑/删除）
class _SingleStatPage extends StatefulWidget {
  final String type;
  final Color color;
  const _SingleStatPage({required this.type, required this.color});
  @override
  State<_SingleStatPage> createState() => _SingleStatPageState();
}

class _SingleStatPageState extends State<_SingleStatPage> {
  bool showChart = true;
  Future<List<Map<String, dynamic>>> _getRecords() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type}统计')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [Icon(Icons.show_chart), Text('图表')],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(children: [Icon(Icons.list), Text('列表')]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(child: showChart ? _buildChart() : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecords(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('暂无${widget.type}记录'));
        }
        final records = snapshot.data!;
        return ListView.separated(
          itemCount: records.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, i) {
            final r = records[i];
            return ListTile(
              leading: Icon(Icons.circle, color: Colors.grey),
              title: Text('${r['value']} ${r['unit']}'),
              subtitle: Text('${r['date'].toString().substring(0, 10)}'),
            );
          },
        );
      },
    );
  }

  Widget _buildChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecords(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return Center(child: Text('暂无${widget.type}记录'));
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
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.type}变化',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    if (unit.isNotEmpty)
                      Text(
                        '单位: $unit',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 220,
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
                            reservedSize: 36,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (!labelDays.contains(value))
                                return Container();
                              int idx = labelDays.indexOf(value);
                              if (idx < 0 || idx >= labelIndexes.length)
                                return Container();
                              final date = dateList[labelIndexes[idx]];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  '${date.month}/${date.day}',
                                  style: TextStyle(fontSize: 12),
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
                          barWidth: 3,
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
                                radius: 3,
                                color: widget.color,
                                strokeWidth: 0,
                                strokeColor: widget.color,
                              );
                            },
                          ),
                          isStrokeCapRound: true,
                          shadow: Shadow(
                            color: widget.color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: Offset(0, 4),
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
                                  fontSize: 13,
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
}
