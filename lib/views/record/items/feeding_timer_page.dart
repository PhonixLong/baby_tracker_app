import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:baby_tracker_app/controllers/items/feeding_timer_controller.dart';
import 'package:baby_tracker_app/utils/dialogs.dart';

class FeedingTimerPage extends GetView<FeedingTimerController> {
  const FeedingTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保controller注入
    Get.put(FeedingTimerController());
    return Scaffold(
      appBar: AppBar(
        title: Text('喂养计时', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('点击开始计时', style: TextStyle(fontSize: 18.sp)),
                SizedBox(height: 32.h),
                Text(
                  '开始时间： ${controller.formatTime(controller.startTime.value)}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                Text(
                  '结束时间：${controller.formatTime(controller.endTime.value)}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 32.h),
                if (controller.isTiming.value)
                  Text(
                    '计时中：${controller.formatElapsed(controller.elapsed.value)}',
                    style: TextStyle(fontSize: 28.sp, color: Colors.blue),
                  ),
                if (!controller.isTiming.value)
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow, size: 24.w),
                    label: Text('开始计时', style: TextStyle(fontSize: 16.sp)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(160.w, 48.h),
                    ),
                    onPressed: controller.startTimer,
                  ),
                if (controller.isTiming.value)
                  ElevatedButton.icon(
                    icon: Icon(Icons.stop, size: 24.w),
                    label: Text('结束计时', style: TextStyle(fontSize: 16.sp)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(160.w, 48.h),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      controller.stopTimer();
                      _showCompleteDialog(context);
                    },
                  ),
                if (controller.duration.value != null)
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: Text(
                      '耗时：${controller.duration.value!.inMinutes}分${controller.duration.value!.inSeconds % 60}秒',
                      style: TextStyle(fontSize: 18.sp, color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    final controller = Get.find<FeedingTimerController>();
    showGetDialog(
      context: context,
      icon: Icon(Icons.local_drink, color: Colors.blue, size: 24.w),
      title: Text(
        '完善喂养信息',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
      ),
      content: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '喂养类型',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.feedingTypes
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type, style: TextStyle(fontSize: 14.sp)),
                      selected: controller.feedingType.value == type,
                      onSelected: (v) {
                        if (v) {
                          controller.feedingType.value = type;
                          controller.amount.value = null;
                          controller.breastAmount.value = null;
                          controller.formulaAmount.value = null;
                          controller.recordBreastByTime.value = false;
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16.h),
            if (controller.feedingType.value == '混合') ...[
              Text(
                '母乳量记录方式',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                children: [
                  ChoiceChip(
                    label: Text('毫升', style: TextStyle(fontSize: 14.sp)),
                    selected: !controller.recordBreastByTime.value,
                    onSelected: (v) {
                      controller.recordBreastByTime.value = false;
                    },
                  ),
                  ChoiceChip(
                    label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                    selected: controller.recordBreastByTime.value,
                    onSelected: (v) {
                      controller.recordBreastByTime.value = true;
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (controller.recordBreastByTime.value)
                _styledInput(
                  label: '母乳时长（分钟）',
                  initial: controller.duration.value != null
                      ? (controller.duration.value!.inMinutes +
                                (controller.duration.value!.inSeconds % 60) /
                                    60.0)
                            .toStringAsFixed(1)
                      : '',
                  onChanged: (v) =>
                      controller.breastAmount.value = double.tryParse(v),
                )
              else
                _styledInput(
                  label: '母乳量（ml）',
                  onChanged: (v) =>
                      controller.breastAmount.value = double.tryParse(v),
                ),
              _styledInput(
                label: '配方奶量（ml）',
                onChanged: (v) =>
                    controller.formulaAmount.value = double.tryParse(v),
              ),
            ] else if (controller.feedingType.value == '母乳') ...[
              Text(
                '母乳量记录方式',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                children: [
                  ChoiceChip(
                    label: Text('毫升', style: TextStyle(fontSize: 14.sp)),
                    selected: !controller.recordBreastByTime.value,
                    onSelected: (v) {
                      controller.recordBreastByTime.value = false;
                    },
                  ),
                  ChoiceChip(
                    label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                    selected: controller.recordBreastByTime.value,
                    onSelected: (v) {
                      controller.recordBreastByTime.value = true;
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (controller.recordBreastByTime.value)
                _styledInput(
                  label: '母乳时长（分钟）',
                  initial: controller.duration.value != null
                      ? (controller.duration.value!.inMinutes +
                                (controller.duration.value!.inSeconds % 60) /
                                    60.0)
                            .toStringAsFixed(1)
                      : '',
                  onChanged: (v) =>
                      controller.amount.value = double.tryParse(v),
                )
              else
                _styledInput(
                  label: '母乳量（ml）',
                  onChanged: (v) =>
                      controller.amount.value = double.tryParse(v),
                ),
            ] else ...[
              _styledInput(
                label: '量（ml）',
                onChanged: (v) => controller.amount.value = double.tryParse(v),
              ),
            ],
            SizedBox(height: 16.h),
            if (controller.duration.value != null)
              Text(
                '耗时：${controller.duration.value!.inMinutes}分${controller.duration.value!.inSeconds % 60}秒',
                style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('取消', style: TextStyle(fontSize: 16.sp)),
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.saveRecord();
            Get.back();
            Get.snackbar('提示', '喂养记录已保存', snackPosition: SnackPosition.BOTTOM);
          },
          child: Text('保存', style: TextStyle(fontSize: 16.sp)),
        ),
      ],
    );
  }

  Widget _styledInput({
    required String label,
    String? initial,
    required Function(String) onChanged,
  }) {
    final controller = TextEditingController(text: initial);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
