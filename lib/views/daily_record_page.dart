import 'package:flutter/material.dart';
import 'record_view.dart';

class _DailyItem {
  final String title;
  final IconData icon;
  final Color color;
  const _DailyItem(this.title, this.icon, this.color);
}

class _DailyCard extends StatelessWidget {
  final _DailyItem item;
  const _DailyCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 处理点击事件
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('点击了"' + item.title + "'")));
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

class DailyRecordPage extends StatelessWidget {
  final List<_DailyItem> items = const [
    _DailyItem('喂养', Icons.local_drink, Colors.blue),
    _DailyItem('辅食', Icons.restaurant, Colors.orange),
    _DailyItem('饮水', Icons.water_drop, Colors.lightBlue),
    _DailyItem('吃药/补充剂', Icons.medication, Colors.redAccent),
    _DailyItem('小便', Icons.wc, Colors.yellow),
    _DailyItem('大便', Icons.wc, Colors.brown),
    _DailyItem('尿布更换', Icons.baby_changing_station, Colors.teal),
    _DailyItem('排便异常', Icons.warning, Colors.deepOrange),
    _DailyItem('入睡', Icons.bedtime, Colors.indigo),
    _DailyItem('醒来', Icons.wb_twilight, Colors.indigoAccent),
    _DailyItem('夜醒', Icons.nightlight, Colors.deepPurple),
    _DailyItem('小睡/午睡', Icons.hotel, Colors.cyan),
    _DailyItem('洗澡', Icons.bathtub, Colors.blueGrey),
    _DailyItem('清洁/洗手', Icons.clean_hands, Colors.green),
    _DailyItem('外出活动', Icons.park, Colors.lightGreen),
    _DailyItem('心情/行为', Icons.emoji_emotions, Colors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCardWidth = 120.0;
    final crossAxisSpacing = 16.0;
    final mainAxisSpacing = 16.0;
    return Scaffold(
      appBar: AppBar(title: Text('日常记录')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '日常小类',
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
            itemBuilder: (context, i) => _DailyCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}
