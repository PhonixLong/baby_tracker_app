import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart'; // Added for TextInputType
import 'package:flutter/widgets.dart'; // Added for Ticker
import 'dart:async';

class RecordView extends StatelessWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_RecordCategory> categories = [
      _RecordCategory(
        title: '日常',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        detailPage: _DailyRecordPage(),
      ),
      _RecordCategory(
        title: '成长',
        icon: Icons.show_chart,
        color: Colors.green,
        detailPage: _GrowthRecordPage(),
      ),
      _RecordCategory(
        title: '医疗',
        icon: Icons.local_hospital,
        color: Colors.redAccent,
        detailPage: _MedicalRecordPage(),
      ),
      _RecordCategory(
        title: '里程',
        icon: Icons.flag,
        color: Colors.blue,
        detailPage: _MilestoneRecordPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('记录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cat.color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: cat.color.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, size: 48, color: cat.color),
                    SizedBox(height: 16),
                    Text(
                      cat.title,
                      style: TextStyle(
                        fontSize: 20,
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

class _DailyRecordPage extends StatelessWidget {
  final List<_DailyItem> items = const [
    _DailyItem('喂养', Icons.local_drink, Colors.blue),
    _DailyItem('辅食', Icons.restaurant, Colors.orange),
    _DailyItem('饮水', Icons.water_drop, Colors.lightBlue),
    _DailyItem('吃药/补充剂', Icons.medication, Colors.redAccent),
    _DailyItem('小便', Icons.wc, Colors.yellow),
    _DailyItem('大便', Icons.wc, Colors.brown),
    _DailyItem('尿布更换', Icons.baby_changing_station, Colors.teal),
    _DailyItem('排便异常', Icons.warning, Colors.deepOrange),
    _DailyItem('入睡', Icons.bedtime, Colors.indigo),
    _DailyItem('醒来', Icons.wb_twilight, Colors.indigoAccent),
    _DailyItem('夜醒', Icons.nightlight, Colors.deepPurple),
    _DailyItem('小睡/午睡', Icons.hotel, Colors.cyan),
    _DailyItem('洗澡', Icons.bathtub, Colors.blueGrey),
    _DailyItem('清洁/洗手', Icons.clean_hands, Colors.green),
    _DailyItem('外出活动', Icons.park, Colors.lightGreen),
    _DailyItem('心情/行为', Icons.emoji_emotions, Colors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCardWidth = 120.0;
    final crossAxisSpacing = 16.0;
    final mainAxisSpacing = 16.0;
    return Scaffold(
      appBar: AppBar(title: Text('日常记录')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '日常小类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCardWidth,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _DailyCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}

class _DailyItem {
  final String title;
  final IconData icon;
  final Color color;
  const _DailyItem(this.title, this.icon, this.color);
}

class _FeedingTimerPage extends StatefulWidget {
  @override
  State<_FeedingTimerPage> createState() => _FeedingTimerPageState();
}

class _FeedingTimerPageState extends State<_FeedingTimerPage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _duration;
  bool _isTiming = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // 喂养类型
  String _feedingType = '母乳';
  final List<String> _feedingTypes = ['母乳', '配方奶', '混合'];
  // 混合喂养时的子类型
  double? _breastAmount;
  double? _formulaAmount;
  double? _amount;
  bool _recordBreastByTime = false; // 母乳量记录方式

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTiming) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

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

  // 优化完善喂养信息弹窗UI，修复Row溢出
  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_drink, color: Colors.blue),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '完善喂养信息',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('喂养类型', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: _feedingTypes
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type),
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
                    SizedBox(height: 16),
                    if (_feedingType == '混合') ...[
                      Text(
                        '母乳量记录方式',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('毫升'),
                            selected: !_recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = false,
                            ),
                          ),
                          ChoiceChip(
                            label: Text('耗时'),
                            selected: _recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
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
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('毫升'),
                            selected: !_recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = false,
                            ),
                          ),
                          ChoiceChip(
                            label: Text('耗时'),
                            selected: _recordBreastByTime,
                            onSelected: (v) => setStateDialog(
                              () => _recordBreastByTime = true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
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
                    SizedBox(height: 16),
                    if (_duration != null)
                      Text(
                        '耗时：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('取消'),
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('喂养记录已保存')));
                  },
                  child: Text('保存'),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      appBar: AppBar(title: Text('喂养计时')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('点击开始计时', style: TextStyle(fontSize: 18)),
              SizedBox(height: 32),
              Text(
                '开始时间：${_formatTime(_startTime)}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '结束时间：${_formatTime(_endTime)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              if (_isTiming)
                Text(
                  '计时中：${_formatElapsed(_elapsed)}',
                  style: TextStyle(fontSize: 28, color: Colors.blue),
                ),
              if (!_isTiming)
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('开始计时'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(160, 48)),
                  onPressed: _startTimer,
                ),
              if (_isTiming)
                ElevatedButton.icon(
                  icon: Icon(Icons.stop),
                  label: Text('结束计时'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160, 48),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _stopTimer,
                ),
              if (_duration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    '耗时：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedingAddRecordPage extends StatefulWidget {
  @override
  State<_FeedingAddRecordPage> createState() => _FeedingAddRecordPageState();
}

class _FeedingAddRecordPageState extends State<_FeedingAddRecordPage> {
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // 优化添加喂养记录页面UI，修复Row溢出
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('添加喂养记录')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('喂养类型', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedingTypes
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type),
                      selected: _feedingType == type,
                      onSelected: (v) {
                        if (v)
                          setState(() {
                            _feedingType = type;
                            _amount = null;
                            _breastAmount = null;
                            _formulaAmount = null;
                            _recordBreastByTime = false; // 默认毫升
                          });
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16),
            if (_feedingType == '混合') ...[
              Text('母乳量记录方式', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text('毫升'),
                    selected: !_recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = false),
                  ),
                  ChoiceChip(
                    label: Text('耗时'),
                    selected: _recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = true),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_recordBreastByTime)
                _styledInput(
                  label: '母乳时长（分钟）',
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
              Text('母乳量记录方式', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text('毫升'),
                    selected: !_recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = false),
                  ),
                  ChoiceChip(
                    label: Text('耗时'),
                    selected: _recordBreastByTime,
                    onSelected: (v) =>
                        setState(() => _recordBreastByTime = true),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_recordBreastByTime)
                _styledInput(
                  label: '母乳时长（分钟）',
                  onChanged: (v) => _amount = double.tryParse(v),
                  initial: _duration != null
                      ? (_duration!.inMinutes +
                                (_duration!.inSeconds % 60) / 60.0)
                            .toStringAsFixed(1)
                      : '',
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
            SizedBox(height: 16),
            Text('喂养时间', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('选择日期'),
                  onPressed: _pickDate,
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('开始: ${_startTime.format(context)}'),
                    SizedBox(width: 8),
                    OutlinedButton(
                      child: Text('选择开始'),
                      onPressed: _pickStartTime,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('结束: ${_endTime.format(context)}'),
                    SizedBox(width: 8),
                    OutlinedButton(
                      child: Text('选择结束'),
                      onPressed: _pickEndTime,
                    ),
                  ],
                ),
              ],
            ),
            if (_duration != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '自动计算时长：${_duration!.inMinutes}分${_duration!.inSeconds % 60}秒',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('保存记录'),
                style: ElevatedButton.styleFrom(minimumSize: Size(160, 48)),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('喂养记录已保存')));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  final _DailyItem item;
  const _DailyCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.title == '喂养') {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '喂养操作',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.timer),
                          label: Text('喂养计时'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _FeedingTimerPage(),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('添加记录'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _FeedingAddRecordPage(),
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
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了${item.title}')));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 38, color: item.color),
            SizedBox(height: 10),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 15,
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

class _GrowthRecordPage extends StatelessWidget {
  final List<_GrowthItem> items = const [
    _GrowthItem('体重', Icons.monitor_weight, Colors.green),
    _GrowthItem('身高', Icons.height, Colors.blue),
    _GrowthItem('头围', Icons.circle, Colors.deepPurple),
    _GrowthItem('牙齿', Icons.emoji_people, Colors.orange),
    _GrowthItem('运动发育', Icons.directions_run, Colors.teal),
    _GrowthItem('语言/认知', Icons.record_voice_over, Colors.pink),
    _GrowthItem('特殊事件', Icons.star, Colors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCardWidth = 120.0;
    final crossAxisSpacing = 16.0;
    final mainAxisSpacing = 16.0;
    return Scaffold(
      appBar: AppBar(title: Text('成长记录')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '成长小类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCardWidth,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _GrowthCard(item: items[i]),
          ),
        ],
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
      onTap: () {
        // TODO: 跳转或弹窗填写记录
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('点击了${item.title}')));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 38, color: item.color),
            SizedBox(height: 10),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 15,
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

class _MedicalRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('医疗记录')),
      body: Center(child: Text('医疗记录内容')), // TODO: 替换为原医疗记录内容
    );
  }
}

class _MilestoneRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('里程记录')),
      body: Center(child: Text('里程记录内容')), // TODO: 替换为原里程记录内容
    );
  }
}

// 统计页面预留入口
class _StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('喂养统计')),
      body: FutureBuilder(
        future: Hive.openBox('feedingRecords'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          final box = Hive.box('feedingRecords');
          if (box.isEmpty) {
            return Center(child: Text('暂无喂养记录'));
          }
          final records = box.values.toList().reversed.toList();
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final r = records[i] as Map;
              return ListTile(
                leading: Icon(Icons.local_drink, color: Colors.blue),
                title: Text('${r['type']}：${r['value']} ${r['unit']}'),
                subtitle: Text(
                  '时间：${DateTime.tryParse(r['date'] ?? '')?.toLocal().toString().substring(0, 16) ?? ''}',
                ),
                trailing: r['duration'] != null
                    ? Text('耗时: ${(r['duration'] / 60).toStringAsFixed(1)} 分')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
