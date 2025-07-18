import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedingAddRecordPage extends StatefulWidget {
  const FeedingAddRecordPage({Key? key}) : super(key: key);
  @override
  State<FeedingAddRecordPage> createState() => _FeedingAddRecordPageState();
}

class _FeedingAddRecordPageState extends State<FeedingAddRecordPage> {
  String _feedingType = '母乳';
  final List<String> _feedingTypes = ['母乳', '配方奶', '混合'];
  bool _recordBreastByTime = false; // 默认毫升在前
  double? _amount;
  double? _breastAmount;
  double? _formulaAmount;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  Duration? _duration;

  void _updateDuration() {
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    setState(() {
      _duration = end.isAfter(start) ? end.difference(start) : null;
    });
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(context: context, initialTime: _startTime);
    if (t != null) {
      setState(() {
        _startTime = t;
        _updateDuration();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(context: context, initialTime: _endTime);
    if (t != null) {
      setState(() {
        _endTime = t;
        _updateDuration();
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _updateDuration();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加喂养记录', style: TextStyle(fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
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
              children: _feedingTypes
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type, style: TextStyle(fontSize: 14.sp)),
                      selected: _feedingType == type,
                      onSelected: (v) {
                        if (v)
                          setState(() {
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
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                children: [
                  ChoiceChip(
                    label: Text('毫升', style: TextStyle(fontSize: 14.sp)),
                    selected: !_recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = false),
                  ),
                  ChoiceChip(
                    label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                    selected: _recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = true),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (!_recordBreastByTime)
                _styledInput(
                  label: '母乳量（ml）',
                  onChanged: (v) => _breastAmount = double.tryParse(v),
                )
              else
                _styledInput(
                  label: '母乳时长（分钟）',
                  onChanged: (v) => _breastAmount = double.tryParse(v),
                ),
              _styledInput(
                label: '配方奶量（ml）',
                onChanged: (v) => _formulaAmount = double.tryParse(v),
              ),
            ] else if (_feedingType == '母乳') ...[
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
                    selected: !_recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = false),
                  ),
                  ChoiceChip(
                    label: Text('耗时', style: TextStyle(fontSize: 14.sp)),
                    selected: _recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = true),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (!_recordBreastByTime)
                _styledInput(
                  label: '母乳量（ml）',
                  onChanged: (v) => _amount = double.tryParse(v),
                )
              else
                _styledInput(
                  label: '母乳时长（分钟）',
                  onChanged: (v) => _amount = double.tryParse(v),
                  initial: _duration != null
                      ? (_duration!.inMinutes +
                                (_duration!.inSeconds % 60) / 60.0)
                            .toStringAsFixed(1)
                      : '',
                ),
            ] else ...[
              _styledInput(
                label: '量（ml）',
                onChanged: (v) => _amount = double.tryParse(v),
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
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  icon: Icon(Icons.edit, size: 20.sp),
                  label: Text('选择日期', style: TextStyle(fontSize: 14.sp)),
                  onPressed: _pickDate,
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
                      '开始: ${_startTime.format(context)}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton(
                      child: Text('选择开始', style: TextStyle(fontSize: 14.sp)),
                      onPressed: _pickStartTime,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '结束: ${_endTime.format(context)}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton(
                      child: Text('选择结束', style: TextStyle(fontSize: 14.sp)),
                      onPressed: _pickEndTime,
                    ),
                  ],
                ),
              ],
            ),
            if (_duration != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  '自动计算时长：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                  style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                ),
              ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save, size: 20.sp),
                label: Text('保存记录', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(minimumSize: Size(160.w, 48.h)),
                onPressed: () async {
                  final box = await Hive.openBox('feedingRecords');
                  final dt = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _startTime.hour,
                    _startTime.minute,
                  );
                  final endDt = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _endTime.hour,
                    _endTime.minute,
                  );
                  final durationSec = _duration?.inSeconds;
                  if (_feedingType == '混合') {
                    if (_breastAmount != null && _breastAmount! > 0) {
                      box.add({
                        'type': _recordBreastByTime ? '母乳(时长)' : '母乳(ml)',
                        'value': _breastAmount,
                        'unit': _recordBreastByTime ? 'min' : 'ml',
                        'date': dt.toIso8601String(),
                        'end': endDt.toIso8601String(),
                        'duration': durationSec,
                      });
                    }
                    if (_formulaAmount != null && _formulaAmount! > 0) {
                      box.add({
                        'type': '配方奶',
                        'value': _formulaAmount,
                        'unit': 'ml',
                        'date': dt.toIso8601String(),
                        'end': endDt.toIso8601String(),
                        'duration': durationSec,
                      });
                    }
                  } else if (_feedingType == '母乳') {
                    if (_amount != null && _amount! > 0) {
                      box.add({
                        'type': _recordBreastByTime ? '母乳(时长)' : '母乳(ml)',
                        'value': _amount,
                        'unit': _recordBreastByTime ? 'min' : 'ml',
                        'date': dt.toIso8601String(),
                        'end': endDt.toIso8601String(),
                        'duration': durationSec,
                      });
                    }
                  } else if (_feedingType == '配方奶') {
                    if (_amount != null && _amount! > 0) {
                      box.add({
                        'type': '配方奶',
                        'value': _amount,
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
                      content: Text(
                        '喂养记录已保存',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
