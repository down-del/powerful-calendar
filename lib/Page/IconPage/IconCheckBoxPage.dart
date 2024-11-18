import 'package:flutter/material.dart';
import 'package:project2/Tool/HomeDownButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // 用于处理日期

/// 事件存储管理类，负责加载和存储事件数据
class EventStorage {
  /// 加载事件数据，返回事件列表
  Future<List<Map<String, dynamic>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonEvents = prefs.getString('events'); // 获取存储中的事件数据

    if (jsonEvents == null) {
      return []; // 如果事件数据不存在，返回空列表
    }

    // 解码存储的 JSON 数据，将其转换为 Dart 的 List 类型
    List<dynamic> decodedList = jsonDecode(jsonEvents);
    return decodedList
        .map((event) => Map<String, dynamic>.from(event)) // 转换每个事件为 Map 结构
        .toList();
  }

  /// 存储事件数据
  Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonEvents = jsonEncode(events); // 将事件列表转换为 JSON 字符串
    await prefs.setString('events', jsonEvents); // 存储到 SharedPreferences
  }
}

/// 主页面：显示事件列表
class IconCheakBox extends StatefulWidget {
  @override
  _IconCheakBoxState createState() => _IconCheakBoxState();
}

class _IconCheakBoxState extends State<IconCheakBox> {
  late Future<List<Map<String, dynamic>>> _events; // 存储事件列表的 Future 类型变量
  final EventStorage _eventStorage = EventStorage(); // 创建事件存储实例

  DateTime _currentDate = DateTime.now(); // 当前日期

  @override
  void initState() {
    super.initState();
    _loadEvents(); // 加载事件数据
  }

  /// 加载事件数据
  void _loadEvents() {
    _events = _eventStorage.loadEvents(); // 调用 EventStorage 类的 loadEvents 方法
  }

  /// 删除事件并更新存储
  Future<void> _deleteEvent(int index) async {
    List<Map<String, dynamic>> events = await _events; // 获取当前事件列表
    events.removeAt(index); // 删除指定索引的事件
    await _eventStorage.saveEvents(events); // 保存更新后的事件列表
    setState(() {
      _loadEvents(); // 刷新页面数据
    });
  }

  /// 切换事件状态（完成/未完成）
  Future<void> _toggleEventStatus(int index) async {
    List<Map<String, dynamic>> events = await _events; // 获取当前事件列表
    events[index]['completed'] = !(events[index]['completed'] ?? false);
    
    // 保存更新后的事件列表
    await _eventStorage.saveEvents(events);
    setState(() {
      _loadEvents(); // 刷新页面数据
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 页面底部按钮，使用自定义组件
      appBar: AppBar(
        title: Text('事件列表'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // FutureBuilder 组件用于异步加载数据
        future: _events, // 设置需要等待的数据源
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 数据加载中
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载数据失败: ${snapshot.error}')); // 显示错误信息
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('没有可显示的事件')); // 如果没有数据，显示提示信息
          }

          List<Map<String, dynamic>> eventsList = snapshot.data!;
          Map<int, Map<int, List<Map<String, dynamic>>>> groupedEvents = {};

          // 将事件按年份和月份分组
          for (var event in eventsList) {
            int year = event['year'];
            int month = event['month'];

            if (!groupedEvents.containsKey(year)) {
              groupedEvents[year] = {};
            }
            if (!groupedEvents[year]!.containsKey(month)) {
              groupedEvents[year]![month] = [];
            }
            groupedEvents[year]![month]!.add(event);
          }

          return ListView(
            children: groupedEvents.entries.map((yearEntry) {
              int year = yearEntry.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$year年', // 显示年份
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...yearEntry.value.entries.map((monthEntry) {
                    // 按月份生成列表
                    int month = monthEntry.key;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '$month月', // 显示月份
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...monthEntry.value.map((event) {
                          // 按事件生成列表项
                          int index = eventsList.indexOf(event);
                          return Dismissible(
                            key: ValueKey(event), // 为每个事件生成唯一的键
                            onDismissed: (_) => _deleteEvent(index), // 向左滑动删除事件
                            background: Container(color: Colors.red), // 删除时的背景颜色
                            child: ListTile(
                              leading: Icon(
                                event['completed'] == true
                                    ? Icons.check_box // 完成状态显示勾选框
                                    : Icons.check_box_outline_blank, // 未完成状态显示空白勾选框
                              ),
                              title: Text(
                                event['event_description'],
                                style: TextStyle(
                                  decoration: event['completed'] == true
                                      ? TextDecoration.lineThrough // 已完成的事件加上删除线
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                  '${event['day']}日 ${event['hour']}:${event['minute']}'), // 显示日期和时间
                              onTap: () => _toggleEventStatus(index), // 点击事件切换完成状态
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 在这里调用 _addNewEvent 方法来添加新的事件
      //     _addNewEvent(2024, 11, 18, 10, 30, "新事件", "每天");
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: '添加事件',
      // ),
    );
  }
}
