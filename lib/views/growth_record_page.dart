import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthRecordPage extends StatelessWidget {
  final List<GrowthItem> items = const [
    GrowthItem('体重', Icons.monitor_weight, Colors.green),
    GrowthItem('身高', Icons.height, Colors.blue),
    GrowthItem('头围', Icons.circle, Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCardWidth = 120.0;
    final crossAxisSpacing = 16.0;
    final mainAxisSpacing = 16.0;
    return Scaffold(
      appBar: AppBar(title: Text('成长记录')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '成长小类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCardWidth,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => GrowthCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}

class GrowthItem {
  final String title;
  final IconData icon;
  final Color color;
  const GrowthItem(this.title, this.icon, this.color);
}

class GrowthCard extends StatelessWidget {
  final GrowthItem item;
  const GrowthCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (item.title == '体重' || item.title == '身高' || item.title == '头围') {
          final controller = TextEditingController();
          DateTime selectedDate = DateTime.now();
          String unit = item.title == '体重' ? 'kg' : 'cm';
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                title: Text('记录${item.title}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: '${item.title}数值（$unit）',
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text('日期: '),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                Duration(days: 365),
                              ),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null)
                              setStateDialog(() => selectedDate = picked);
                          },
                          child: Text(
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(controller.text);
                      if (value != null) {
                        Navigator.of(
                          context,
                        ).pop({'value': value, 'date': selectedDate});
                      }
                    },
                    child: Text('保存'),
                  ),
                ],
              ),
            ),
          );
          if (result != null) {
            final box = await Hive.openBox('growthRecords');
            box.add({
              'type': item.title,
              'value': result['value'],
              'unit': unit,
              'date': result['date'].toIso8601String(),
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('${item.title}记录已保存')));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了${item.title}')));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 38, color: item.color),
            SizedBox(height: 10),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 15,
                color: item.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrowthStatsPage extends StatefulWidget {
  const GrowthStatsPage({Key? key}) : super(key: key);

  @override
  State<GrowthStatsPage> createState() => _GrowthStatsPageState();
}

class _GrowthStatsPageState extends State<GrowthStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _types = ['体重', '身高', '头围'];
  final List<Color> _colors = [Colors.green, Colors.blue, Colors.deepPurple];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map>> _getRecords(String type) async {
    final box = await Hive.openBox('growthRecords');
    final records = box.values
        .where((r) => r is Map && r['type'] == type)
        .cast<Map>()
        .toList();
    records.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    return records;
  }

  Widget _buildChart(String type, Color color) {
    return FutureBuilder<List<Map>>(
      future: _getRecords(type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return Center(child: Text('暂无$type记录'));
        }
        final spots = <FlSpot>[];
        for (int i = 0; i < records.length; i++) {
          final value = (records[i]['value'] as num?)?.toDouble() ?? 0;
          spots.add(FlSpot(i.toDouble(), value));
        }
        final unit = records.first['unit'] ?? '';
        // 计算x轴标签索引（首、末、均匀分布，最多5个）
        List<int> labelIndexes = [];
        if (records.length <= 5) {
          labelIndexes = List.generate(records.length, (i) => i);
        } else {
          labelIndexes = [0];
          int step = (records.length - 1) ~/ 4;
          for (int i = 1; i < 4; i++) {
            labelIndexes.add(i * step);
          }
          labelIndexes.add(records.length - 1);
        }
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
                      '$type变化',
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
                      minY:
                          spots
                              .map((e) => e.y)
                              .reduce((a, b) => a < b ? a : b) -
                          1,
                      maxY:
                          spots
                              .map((e) => e.y)
                              .reduce((a, b) => a > b ? a : b) +
                          1,
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
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (!labelIndexes.contains(idx))
                                return Container();
                              final date = DateTime.tryParse(
                                records[idx]['date'] ?? '',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  date != null
                                      ? '${date.month}/${date.day}'
                                      : '',
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
                        horizontalInterval: 1,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: color,
                              );
                            },
                          ),
                          isStrokeCapRound: true,
                          shadow: Shadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchCallback: (event, response) async {
                          if (event is FlTapUpEvent &&
                              response != null &&
                              response.lineBarSpots != null &&
                              response.lineBarSpots!.isNotEmpty) {
                            final idx = response.lineBarSpots!.first.x.toInt();
                            final record = records[idx];
                            final controller = TextEditingController(
                              text: record['value'].toString(),
                            );
                            DateTime selectedDate =
                                DateTime.tryParse(record['date']) ??
                                DateTime.now();
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setStateDialog) => AlertDialog(
                                  title: Text('编辑$type记录'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: controller,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          labelText:
                                              '$type数值（${record['unit'] ?? ''}）',
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text('日期: '),
                                          TextButton(
                                            onPressed: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: selectedDate,
                                                    firstDate: DateTime.now()
                                                        .subtract(
                                                          Duration(days: 365),
                                                        ),
                                                    lastDate: DateTime.now(),
                                                  );
                                              if (picked != null)
                                                setStateDialog(
                                                  () => selectedDate = picked,
                                                );
                                            },
                                            child: Text(
                                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final box = await Hive.openBox(
                                          'growthRecords',
                                        );
                                        final key = box.keyAt(idx);
                                        await box.delete(key);
                                        Navigator.of(
                                          context,
                                        ).pop({'deleted': true});
                                      },
                                      child: Text(
                                        '删除',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final value = double.tryParse(
                                          controller.text,
                                        );
                                        if (value != null) {
                                          Navigator.of(context).pop({
                                            'value': value,
                                            'date': selectedDate,
                                          });
                                        }
                                      },
                                      child: Text('保存'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (result != null) {
                              final box = await Hive.openBox('growthRecords');
                              final key = box.keyAt(idx);
                              if (result['deleted'] == true) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$type记录已删除')),
                                );
                              } else {
                                await box.put(key, {
                                  'type': type,
                                  'value': result['value'],
                                  'unit': record['unit'],
                                  'date': result['date'].toIso8601String(),
                                });
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$type记录已更新')),
                                );
                              }
                            }
                          }
                        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('成长统计'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: 导出/分享功能
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _types.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_types.length, (i) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: _buildChart(_types[i], _colors[i])),
                FutureBuilder<List<Map>>(
                  future: _getRecords(_types[i]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('暂无${_types[i]}记录');
                    }
                    final last = snapshot.data!.last;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '最近：${last['value']} ${last['unit']}  ${last['date'].toString().substring(0, 10)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
