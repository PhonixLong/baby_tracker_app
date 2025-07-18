import 'package:flutter/material.dart';
import 'package:baby_tracker_app/utils/snackbar.dart';
import 'items/feeding_timer_page.dart';
import 'items/feeding_add_record_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:baby_tracker_app/utils/dialogs.dart';

class DailyRecordPage extends StatelessWidget {
  final List<DailyItem> items = const [
    DailyItem('喂养', Icons.local_drink, Colors.blue),
    DailyItem('辅食', Icons.restaurant, Colors.orange),
    DailyItem('小便', Icons.wc, Colors.yellow),
    DailyItem('大便', Icons.wc, Colors.brown),
    DailyItem('睡眠', Icons.bedtime, Colors.indigo),
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
        } else if (item.title == '小便' ||
            item.title == '大便' ||
            item.title == '睡眠') {
          final remarkController = TextEditingController();
          DateTime selectedDate = DateTime.now();
          TimeOfDay selectedTime = TimeOfDay.now();
          XFile? selectedImage;
          final picker = ImagePicker();
          showGetDialog(
            context: context,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: item.color, size: 24.w),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '添加${item.title}记录',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final box = await Hive.openBox('dailyRecords');
                  final dt = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  await box.add({
                    'type': item.title,
                    'date': dt.toIso8601String(),
                    'remark': remarkController.text,
                    if (item.title == '大便' && selectedImage != null)
                      'image': selectedImage!.path,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildNiceSnackBar(
                      context,
                      '${item.title}记录已保存',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  );
                },
                child: Text('保存'),
              ),
            ],
            content: StatefulBuilder(
              builder: (ctx, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('时间', style: TextStyle(fontSize: 15.sp)),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedTime.format(context)}',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton(
                        child: Text('选择', style: TextStyle(fontSize: 13.sp)),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(Duration(days: 1)),
                          );
                          if (d != null) setState(() => selectedDate = d);
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (t != null) setState(() => selectedTime = t);
                        },
                      ),
                    ],
                  ),
                  if (item.title == '大便') ...[
                    SizedBox(height: 12.h),
                    Text('照片', style: TextStyle(fontSize: 15.sp)),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.camera_alt),
                          label: Text('拍照'),
                          onPressed: () async {
                            final img = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                            );
                            if (img != null)
                              setState(() => selectedImage = img);
                          },
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton.icon(
                          icon: Icon(Icons.photo_library),
                          label: Text('相册'),
                          onPressed: () async {
                            final img = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );
                            if (img != null)
                              setState(() => selectedImage = img);
                          },
                        ),
                      ],
                    ),
                    if (selectedImage != null) ...[
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(selectedImage!.path),
                          width: 120.w,
                          height: 120.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                  SizedBox(height: 12.h),
                  Text('备注', style: TextStyle(fontSize: 15.sp)),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      hintText: '可填写补充说明',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          );
        } else if (item.title == '辅食') {
          ScaffoldMessenger.of(context).showSnackBar(
            buildNiceSnackBar(
              context,
              '辅食功能敬请期待',
              icon: Icons.info_outline,
              color: Colors.blue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            buildNiceSnackBar(
              context,
              '点击了"${item.title}"',
              icon: Icons.info_outline,
              color: Colors.blue,
            ),
          );
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
