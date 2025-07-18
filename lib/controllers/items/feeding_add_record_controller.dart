import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedingAddRecordController extends GetxController {
  var feedingType = '母乳'.obs;
  final feedingTypes = ['母乳', '配方奶', '混合'];
  var recordBreastByTime = false.obs;
  var amount = RxnDouble();
  var breastAmount = RxnDouble();
  var formulaAmount = RxnDouble();
  var selectedDate = DateTime.now().obs;
  var startTime = TimeOfDay.now().obs;
  var endTime = TimeOfDay.now().obs;
  var duration = Rxn<Duration>();

  void updateDuration() {
    final start = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      startTime.value.hour,
      startTime.value.minute,
    );
    final end = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      endTime.value.hour,
      endTime.value.minute,
    );
    duration.value = end.isAfter(start) ? end.difference(start) : null;
  }

  Future<void> pickStartTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: startTime.value,
    );
    if (t != null) {
      startTime.value = t;
      updateDuration();
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: endTime.value,
    );
    if (t != null) {
      endTime.value = t;
      updateDuration();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      selectedDate.value = date;
      updateDuration();
    }
  }

  Future<void> saveRecord(BuildContext context) async {
    final box = await Hive.openBox('feedingRecords');
    final dt = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      startTime.value.hour,
      startTime.value.minute,
    );
    final endDt = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      endTime.value.hour,
      endTime.value.minute,
    );
    final durationSec = duration.value?.inSeconds;
    if (feedingType.value == '混合') {
      if (breastAmount.value != null && breastAmount.value! > 0) {
        box.add({
          'type': recordBreastByTime.value ? '母乳(时长)' : '母乳(ml)',
          'value': breastAmount.value,
          'unit': recordBreastByTime.value ? 'min' : 'ml',
          'date': dt.toIso8601String(),
          'end': endDt.toIso8601String(),
          'duration': durationSec,
        });
      }
      if (formulaAmount.value != null && formulaAmount.value! > 0) {
        box.add({
          'type': '配方奶',
          'value': formulaAmount.value,
          'unit': 'ml',
          'date': dt.toIso8601String(),
          'end': endDt.toIso8601String(),
          'duration': durationSec,
        });
      }
    } else if (feedingType.value == '母乳') {
      if (amount.value != null && amount.value! > 0) {
        box.add({
          'type': recordBreastByTime.value ? '母乳(时长)' : '母乳(ml)',
          'value': amount.value,
          'unit': recordBreastByTime.value ? 'min' : 'ml',
          'date': dt.toIso8601String(),
          'end': endDt.toIso8601String(),
          'duration': durationSec,
        });
      }
    } else if (feedingType.value == '配方奶') {
      if (amount.value != null && amount.value! > 0) {
        box.add({
          'type': '配方奶',
          'value': amount.value,
          'unit': 'ml',
          'date': dt.toIso8601String(),
          'end': endDt.toIso8601String(),
          'duration': durationSec,
        });
      }
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('喂养记录已保存', style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}
