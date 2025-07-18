import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedingTimerController extends GetxController {
  var startTime = Rxn<DateTime>();
  var endTime = Rxn<DateTime>();
  var duration = Rxn<Duration>();
  var isTiming = false.obs;
  Timer? timer;
  var elapsed = Duration.zero.obs;

  var feedingType = '母乳'.obs;
  final feedingTypes = ['母乳', '配方奶', '混合'];
  var breastAmount = RxnDouble();
  var formulaAmount = RxnDouble();
  var amount = RxnDouble();
  var recordBreastByTime = false.obs;

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    startTime.value = DateTime.now();
    isTiming.value = true;
    endTime.value = null;
    duration.value = null;
    elapsed.value = Duration.zero;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (isTiming.value && startTime.value != null) {
        elapsed.value = DateTime.now().difference(startTime.value!);
      }
    });
  }

  void stopTimer() {
    endTime.value = DateTime.now();
    isTiming.value = false;
    if (startTime.value != null && endTime.value != null) {
      duration.value = endTime.value!.difference(startTime.value!);
    }
    timer?.cancel();
  }

  Future<void> saveRecord() async {
    final box = await Hive.openBox('feedingRecords');
    final now = DateTime.now();
    if (feedingType.value == '混合') {
      if (breastAmount.value != null && breastAmount.value! > 0) {
        box.add({
          'type': recordBreastByTime.value ? '母乳(时长)' : '母乳(ml)',
          'value': breastAmount.value,
          'unit': recordBreastByTime.value ? 'min' : 'ml',
          'date': now.toIso8601String(),
          'duration': duration.value?.inSeconds,
        });
      }
      if (formulaAmount.value != null && formulaAmount.value! > 0) {
        box.add({
          'type': '配方奶',
          'value': formulaAmount.value,
          'unit': 'ml',
          'date': now.toIso8601String(),
          'duration': duration.value?.inSeconds,
        });
      }
    } else if (feedingType.value == '母乳') {
      if (amount.value != null && amount.value! > 0) {
        box.add({
          'type': recordBreastByTime.value ? '母乳(时长)' : '母乳(ml)',
          'value': amount.value,
          'unit': recordBreastByTime.value ? 'min' : 'ml',
          'date': now.toIso8601String(),
          'duration': duration.value?.inSeconds,
        });
      }
    } else if (feedingType.value == '配方奶') {
      if (amount.value != null && amount.value! > 0) {
        box.add({
          'type': '配方奶',
          'value': amount.value,
          'unit': 'ml',
          'date': now.toIso8601String(),
          'duration': duration.value?.inSeconds,
        });
      }
    }
  }

  String formatTime(DateTime? t) {
    if (t == null) return '--:--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}
