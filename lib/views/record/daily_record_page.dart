import 'package:flutter/material.dart';

class DailyRecordPage extends StatelessWidget {
  final List<DailyItem> items = const [
    DailyItem('喂养', Icons.local_drink, Colors.blue),
    DailyItem('辅食', Icons.restaurant, Colors.orange),
    DailyItem('饮水', Icons.water_drop, Colors.lightBlue),
    DailyItem('吃药/补充剂', Icons.medication, Colors.redAccent),
    DailyItem('小便', Icons.wc, Colors.yellow),
    DailyItem('大便', Icons.wc, Colors.brown),
    DailyItem('尿布更换', Icons.baby_changing_station, Colors.teal),
    DailyItem('排便异常', Icons.warning, Colors.deepOrange),
    DailyItem('入睡', Icons.bedtime, Colors.indigo),
    DailyItem('醒来', Icons.wb_twilight, Colors.indigoAccent),
    DailyItem('夜醒', Icons.nightlight, Colors.deepPurple),
    DailyItem('小睡/午睡', Icons.hotel, Colors.cyan),
    DailyItem('洗澡', Icons.bathtub, Colors.blueGrey),
    DailyItem('清洁/洗手', Icons.clean_hands, Colors.green),
    DailyItem('外出活动', Icons.park, Colors.lightGreen),
    DailyItem('心情/行为', Icons.emoji_emotions, Colors.amber),
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
            itemBuilder: (context, i) => DailyCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}

class DailyItem {
  final String title;
  final IconData icon;
  final Color color;
  const DailyItem(this.title, this.icon, this.color);
}

class DailyCard extends StatelessWidget {
  final DailyItem item;
  const DailyCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.title == '喂养') {
          // TODO: 迁移喂养相关弹窗逻辑
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
