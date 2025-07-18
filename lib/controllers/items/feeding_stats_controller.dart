import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class FeedingStatsController extends GetxController {
  var records = <Map<dynamic, dynamic>>[].obs;
  var grouped = <String, List<Map<dynamic, dynamic>>>{}.obs;
  var sortedDates = <String>[].obs;
  var weekStats = <String, dynamic>{}.obs;
  var monthStats = <String, dynamic>{}.obs;
  var trend = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final box = await Hive.openBox('feedingRecords');
    final recs = box.values.toList().cast<Map<dynamic, dynamic>>();
    records.value = recs;
    _groupAndStat();
  }

  void _groupAndStat() {
    final map = <String, List<Map<dynamic, dynamic>>>{};
    for (final r in records) {
      final date = (r['date'] ?? '').toString().substring(0, 10);
      map.putIfAbsent(date, () => []).add(r);
    }
    grouped.value = map;
    sortedDates.value = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    weekStats.value = _calcPeriodStats(records, weekStart, weekEnd);
    monthStats.value = _calcPeriodStats(records, monthStart, monthEnd);
    // 近7天趋势
    final last7Days = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );
    trend.value = last7Days.map((d) {
      final key = d.toIso8601String().substring(0, 10);
      final day = (grouped[key] ?? []);
      final stats = calcDayStats(day);
      return {
        'date': key,
        'totalMl': stats['totalMl'] ?? 0.0,
        'breastMl': stats['breastMl'] ?? 0.0,
        'formulaMl': stats['formulaMl'] ?? 0.0,
      };
    }).toList();
  }

  Map<String, dynamic> calcDayStats(List<Map<dynamic, dynamic>> dayRecords) {
    double totalMl = 0;
    double totalMin = 0;
    int count = dayRecords.length;
    double breastMl = 0;
    double formulaMl = 0;
    double breastMin = 0;
    double formulaMin = 0;
    int breastCount = 0;
    int formulaCount = 0;
    int totalDuration = 0;
    for (final r in dayRecords) {
      final value = (r['value'] ?? 0).toDouble();
      final unit = r['unit'] ?? '';
      final type = r['type'] ?? '';
      if (unit == 'ml') {
        totalMl += value;
        if (type.toString().contains('母乳')) {
          breastMl += value;
          breastCount++;
        } else if (type.toString().contains('配方奶')) {
          formulaMl += value;
          formulaCount++;
        }
      } else if (unit == 'min') {
        totalMin += value;
        if (type.toString().contains('母乳')) {
          breastMin += value;
        } else if (type.toString().contains('配方奶')) {
          formulaMin += value;
        }
      }
      if (r['duration'] != null) {
        totalDuration += (r['duration'] as num).toInt();
      }
    }
    return {
      'totalMl': totalMl,
      'totalMin': totalMin,
      'count': count,
      'totalDuration': totalDuration,
      'breastMl': breastMl,
      'formulaMl': formulaMl,
      'breastMin': breastMin,
      'formulaMin': formulaMin,
      'breastCount': breastCount,
      'formulaCount': formulaCount,
    };
  }

  Map<String, dynamic> _calcPeriodStats(
    List<Map<dynamic, dynamic>> records,
    DateTime start,
    DateTime end,
  ) {
    double totalMl = 0, breastMl = 0, formulaMl = 0;
    int count = 0, breastCount = 0, formulaCount = 0, totalDuration = 0;
    for (final r in records) {
      final date = DateTime.tryParse(r['date'] ?? '') ?? DateTime(2000);
      if (date.isBefore(start) || date.isAfter(end)) continue;
      final value = (r['value'] ?? 0).toDouble();
      final unit = r['unit'] ?? '';
      final type = r['type'] ?? '';
      if (unit == 'ml') {
        totalMl += value;
        if (type.toString().contains('母乳')) {
          breastMl += value;
          breastCount++;
        } else if (type.toString().contains('配方奶')) {
          formulaMl += value;
          formulaCount++;
        }
      }
      if (r['duration'] != null) {
        totalDuration += (r['duration'] as num).toInt();
      }
      count++;
    }
    return {
      'totalMl': totalMl,
      'breastMl': breastMl,
      'formulaMl': formulaMl,
      'count': count,
      'breastCount': breastCount,
      'formulaCount': formulaCount,
      'totalDuration': totalDuration,
    };
  }

  Future<void> editRecord(Map<dynamic, dynamic> record, double newValue) async {
    final box = await Hive.openBox('feedingRecords');
    final key = box.keys.elementAt(box.values.toList().indexOf(record));
    await box.put(key, {...record, 'value': newValue});
    await loadRecords();
  }

  Future<void> deleteRecord(Map<dynamic, dynamic> record) async {
    final box = await Hive.openBox('feedingRecords');
    final key = box.keys.elementAt(box.values.toList().indexOf(record));
    await box.delete(key);
    await loadRecords();
  }
}
