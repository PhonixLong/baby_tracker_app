import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedingTimerPage extends StatefulWidget {
  const FeedingTimerPage({Key? key}) : super(key: key);
  @override
  State<FeedingTimerPage> createState() => _FeedingTimerPageState();
}

class _FeedingTimerPageState extends State<FeedingTimerPage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _duration;
  bool _isTiming = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  String _feedingType = '母乳';
  final List<String> _feedingTypes = ['母乳', '配方奶', '混合'];
  double? _breastAmount;
  double? _formulaAmount;
  double? _amount;
  bool _recordBreastByTime = false; // 默认毫升

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _startTime = DateTime.now();
      _isTiming = true;
      _endTime = null;
      _duration = null;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTiming) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _endTime = DateTime.now();
      _isTiming = false;
      _duration = _endTime!.difference(_startTime!);
      _timer?.cancel();
    });
    _showCompleteDialog();
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_drink, color: Colors.blue, size: 24.w),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      '完善喂养信息',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '喂养类型',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _feedingTypes
                          .map(
                            (type) => ChoiceChip(
                              label: Text(
                                type,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              selected: _feedingType == type,
                              onSelected: (v) {
                                if (v)
                                  setStateDialog(() {
                                    _feedingType = type;
                                    _amount = null;
                                    _breastAmount = null;
                                    _formulaAmount = null;
                                    _recordBreastByTime = false;
                                  });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 16.h),
                    if (_feedingType == '混合') ...[
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
                            label: Text(
                              '毫升',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: !_recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = false,
                            ),
                          ),
                          ChoiceChip(
                            label: Text(
                              '耗时',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: _recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (_recordBreastByTime)
                        _styledInput(
                          label: '母乳时长（分钟）',
                          initial: _duration != null
                              ? (_duration!.inMinutes +
                                        (_duration!.inSeconds % 60) / 60.0)
                                    .toStringAsFixed(1)
                              : '',
                          onChanged: (v) => _breastAmount = double.tryParse(v),
                        )
                      else
                        _styledInput(
                          label: '母乳量（ml）',
                          onChanged: (v) => _breastAmount = double.tryParse(v),
                        ),
                      _styledInput(
                        label: '配方奶量（ml）',
                        onChanged: (v) => _formulaAmount = double.tryParse(v),
                      ),
                    ] else if (_feedingType == '母乳') ...[
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
                            label: Text(
                              '毫升',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: !_recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = false,
                            ),
                          ),
                          ChoiceChip(
                            label: Text(
                              '耗时',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: _recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (_recordBreastByTime)
                        _styledInput(
                          label: '母乳时长（分钟）',
                          initial: _duration != null
                              ? (_duration!.inMinutes +
                                        (_duration!.inSeconds % 60) / 60.0)
                                    .toStringAsFixed(1)
                              : '',
                          onChanged: (v) => _amount = double.tryParse(v),
                        )
                      else
                        _styledInput(
                          label: '母乳量（ml）',
                          onChanged: (v) => _amount = double.tryParse(v),
                        ),
                    ] else ...[
                      _styledInput(
                        label: '量（ml）',
                        onChanged: (v) => _amount = double.tryParse(v),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    if (_duration != null)
                      Text(
                        '耗时：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16.sp,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('取消', style: TextStyle(fontSize: 16.sp)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final box = await Hive.openBox('feedingRecords');
                    final now = DateTime.now();
                    if (_feedingType == '混合') {
                      if (_breastAmount != null && _breastAmount! > 0) {
                        box.add({
                          'type': _recordBreastByTime ? '母乳(时长)' : '母乳(ml)',
                          'value': _breastAmount,
                          'unit': _recordBreastByTime ? 'min' : 'ml',
                          'date': now.toIso8601String(),
                          'duration': _duration?.inSeconds,
                        });
                      }
                      if (_formulaAmount != null && _formulaAmount! > 0) {
                        box.add({
                          'type': '配方奶',
                          'value': _formulaAmount,
                          'unit': 'ml',
                          'date': now.toIso8601String(),
                          'duration': _duration?.inSeconds,
                        });
                      }
                    } else if (_feedingType == '母乳') {
                      if (_amount != null && _amount! > 0) {
                        box.add({
                          'type': _recordBreastByTime ? '母乳(时长)' : '母乳(ml)',
                          'value': _amount,
                          'unit': _recordBreastByTime ? 'min' : 'ml',
                          'date': now.toIso8601String(),
                          'duration': _duration?.inSeconds,
                        });
                      }
                    } else if (_feedingType == '配方奶') {
                      if (_amount != null && _amount! > 0) {
                        box.add({
                          'type': '配方奶',
                          'value': _amount,
                          'unit': 'ml',
                          'date': now.toIso8601String(),
                          'duration': _duration?.inSeconds,
                        });
                      }
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '喂养记录已保存',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    );
                  },
                  child: Text('保存', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            );
          },
        );
      },
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

  String _formatTime(DateTime? t) {
    if (t == null) return '--:--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('喂养计时', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('点击开始计时', style: TextStyle(fontSize: 18.sp)),
              SizedBox(height: 32.h),
              Text(
                '开始时间： ${_formatTime(_startTime)}',
                style: TextStyle(fontSize: 16.sp),
              ),
              Text(
                '结束时间：${_formatTime(_endTime)}',
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 32.h),
              if (_isTiming)
                Text(
                  '计时中：${_formatElapsed(_elapsed)}',
                  style: TextStyle(fontSize: 28.sp, color: Colors.blue),
                ),
              if (!_isTiming)
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow, size: 24.w),
                  label: Text('开始计时', style: TextStyle(fontSize: 16.sp)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160.w, 48.h),
                  ),
                  onPressed: _startTimer,
                ),
              if (_isTiming)
                ElevatedButton.icon(
                  icon: Icon(Icons.stop, size: 24.w),
                  label: Text('结束计时', style: TextStyle(fontSize: 16.sp)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160.w, 48.h),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _stopTimer,
                ),
              if (_duration != null)
                Padding(
                  padding: EdgeInsets.only(top: 24.h),
                  child: Text(
                    '耗时：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                    style: TextStyle(fontSize: 18.sp, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
