import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:baby_tracker_app/utils/dialogs.dart';

// 这里只保留成长记录相关内容，统计相关已迁移到stats_home_page.dart

class GrowthRecordPage extends StatelessWidget {
  final List<_GrowthItem> items = const [
    _GrowthItem('体重', Icons.monitor_weight, Colors.green),
    _GrowthItem('身高', Icons.height, Colors.blue),
    _GrowthItem('头围', Icons.circle, Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('成长记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成长项目',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _GrowthCard(item: items[i]),
            ),
          ],
        ),
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
      onTap: () => _showGrowthDialog(context, item),
      child: Container(
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

  void _showGrowthDialog(BuildContext context, _GrowthItem item) {
    DateTime selectedDate = DateTime.now();
    TextEditingController valueController = TextEditingController();
    showNiceDialog(
      context: context,
      icon: Icon(item.icon, color: item.color),
      title: Text(
        '记录${item.title}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('日期', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  SizedBox(width: 8.w),
                  OutlinedButton(
                    child: Text('选择日期'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '${item.title}数值',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText:
                      '请输入${item.title} (${item.title == '体重'
                          ? 'kg'
                          : item.title == '身高'
                          ? 'cm'
                          : 'cm'})',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            final value = double.tryParse(valueController.text);
            if (value == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('请输入有效的${item.title}数值')));
              return;
            }
            final box = await Hive.openBox('growthRecords');
            box.add({
              'type': item.title,
              'value': value,
              'unit': item.title == '体重' ? 'kg' : 'cm',
              'date': selectedDate.toIso8601String(),
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('${item.title}记录已保存')));
          },
          child: Text('保存'),
        ),
      ],
      maxWidth: 0.8,
      borderRadius: 16,
    );
  }
}
