import 'package:flutter/material.dart';
import 'record_view.dart';

class GrowthRecordPage extends StatelessWidget {
  final List<_GrowthItem> items = const [
    _GrowthItem('体重', Icons.monitor_weight, Colors.green),
    _GrowthItem('身高', Icons.height, Colors.blue),
    _GrowthItem('头围', Icons.circle, Colors.deepPurple),
    _GrowthItem('牙齿', Icons.emoji_people, Colors.orange),
    _GrowthItem('运动发育', Icons.directions_run, Colors.teal),
    _GrowthItem('语言/认知', Icons.record_voice_over, Colors.pink),
    _GrowthItem('特殊事件', Icons.star, Colors.amber),
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
            itemBuilder: (context, i) => _GrowthCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}

class _GrowthItem {
  final String title;
  final IconData icon;
  final Color color;
  const _GrowthItem(this.title, this.icon, this.color);
}

class _GrowthCard extends StatelessWidget {
  final _GrowthItem item;
  const _GrowthCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转或弹窗填写记录
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('点击了' + item.title)));
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
