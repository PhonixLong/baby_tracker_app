import 'package:flutter/material.dart';
import 'items/feeding_timer_page.dart';
import 'items/feeding_add_record_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('日常记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            '日常小类',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120.w,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
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
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '喂养操作',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.timer),
                          label: Text('喂养计时'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120.w, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FeedingTimerPage(),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('添加记录'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120.w, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FeedingAddRecordPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了"${item.title}"')));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: item.color, width: 1.5.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 38.w, color: item.color),
            SizedBox(height: 10.h),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 15.sp,
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
