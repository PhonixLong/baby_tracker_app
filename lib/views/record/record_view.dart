import 'package:flutter/material.dart';
import 'daily_record_page.dart';
import 'growth_record_page.dart';
import 'medical_record_page.dart';
import 'milestone_record_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordView extends StatelessWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_RecordCategory> categories = [
      _RecordCategory(
        title: '日常',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        detailPage: DailyRecordPage(),
      ),
      _RecordCategory(
        title: '成长',
        icon: Icons.show_chart,
        color: Colors.green,
        detailPage: GrowthRecordPage(),
      ),
      _RecordCategory(
        title: '医疗',
        icon: Icons.local_hospital,
        color: Colors.redAccent,
        detailPage: MedicalRecordPage(),
      ),
      _RecordCategory(
        title: '里程',
        icon: Icons.flag,
        color: Colors.blue,
        detailPage: MilestoneRecordPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 24.h,
          crossAxisSpacing: 24.w,
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => cat.detailPage));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: cat.color, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: cat.color.withOpacity(0.08),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, size: 48.w, color: cat.color),
                    SizedBox(height: 16.h),
                    Text(
                      cat.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: cat.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecordCategory {
  final String title;
  final IconData icon;
  final Color color;
  final Widget detailPage;
  _RecordCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.detailPage,
  });
}
