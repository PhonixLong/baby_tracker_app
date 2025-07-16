import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatsPage extends StatelessWidget {
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
