import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:baby_tracker_app/controllers/items/feeding_add_record_controller.dart';

class FeedingAddRecordPage extends GetView<FeedingAddRecordController> {
  const FeedingAddRecordPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    // 确保controller注入
    Get.put(FeedingAddRecordController());
    return Scaffold(
      appBar: AppBar(
        title: Text('添加喂养记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Obx(
          () => Column(
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    ChoiceChip(
                      label: Text('毫升', style: TextStyle(fontSize: 14.sp)),
                      selected: !controller.recordBreastByTime.value,
                      onSelected: (v) =>
                          controller.recordBreastByTime.value = false,
                    ),
                    ChoiceChip(
                      label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                      selected: controller.recordBreastByTime.value,
                      onSelected: (v) =>
                          controller.recordBreastByTime.value = true,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (!controller.recordBreastByTime.value)
                  _styledInput(
                    label: '母乳量（ml）',
                    onChanged: (v) =>
                        controller.breastAmount.value = double.tryParse(v),
                  )
                else
                  _styledInput(
                    label: '母乳时长（分钟）',
                    onChanged: (v) =>
                        controller.breastAmount.value = double.tryParse(v),
                  ),
                _styledInput(
                  label: '配方奶量（ml）',
                  onChanged: (v) =>
                      controller.formulaAmount.value = double.tryParse(v),
                ),
                Text(
                  '母乳量记录方式',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    ChoiceChip(
                      label: Text('毫升', style: TextStyle(fontSize: 14.sp)),
                      selected: !controller.recordBreastByTime.value,
                      onSelected: (v) =>
                          controller.recordBreastByTime.value = false,
                    ),
                    ChoiceChip(
                      label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                      selected: controller.recordBreastByTime.value,
                      onSelected: (v) =>
                          controller.recordBreastByTime.value = true,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (!controller.recordBreastByTime.value)
                  _styledInput(
                    label: '母乳量（ml）',
                    onChanged: (v) =>
                        controller.amount.value = double.tryParse(v),
                  )
                else
                  _styledInput(
                    label: '母乳时长（分钟）',
                    onChanged: (v) =>
                        controller.amount.value = double.tryParse(v),
                    initial: controller.duration.value != null
                        ? (controller.duration.value!.inMinutes +
                                  (controller.duration.value!.inSeconds % 60) /
                                      60.0)
                              .toStringAsFixed(1)
                        : '',
                  ),
              ] else ...[
                _styledInput(
                  label: '量（ml）',
                  onChanged: (v) =>
                      controller.amount.value = double.tryParse(v),
                ),
              ],
              SizedBox(height: 16.h),
              Text(
                '喂养时间',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    '${controller.selectedDate.value.year}-${controller.selectedDate.value.month.toString().padLeft(2, '0')}-${controller.selectedDate.value.day.toString().padLeft(2, '0')}',
                  ),
                  SizedBox(width: 8.w),
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit, size: 20.sp),
                    label: Text('选择日期', style: TextStyle(fontSize: 14.sp)),
                    onPressed: () => controller.pickDate(context),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '开始: ${controller.startTime.value.format(context)}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton(
                        child: Text('选择开始', style: TextStyle(fontSize: 14.sp)),
                        onPressed: () => controller.pickStartTime(context),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '结束: ${controller.endTime.value.format(context)}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton(
                        child: Text('选择结束', style: TextStyle(fontSize: 14.sp)),
                        onPressed: () => controller.pickEndTime(context),
                      ),
                    ],
                  ),
                ],
              ),
              if (controller.duration.value != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    '自动计算时长：${controller.duration.value!.inMinutes}分${controller.duration.value!.inSeconds % 60}秒',
                    style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                  ),
                ),
              SizedBox(height: 24.h),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save, size: 20.sp),
                  label: Text('保存记录', style: TextStyle(fontSize: 16.sp)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160.w, 48.h),
                  ),
                  onPressed: () => controller.saveRecord(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
