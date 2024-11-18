import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/*暫時先不開發這部分

/// 事件存储管理类，负责加载和存储消費数据
class SpendStorage {
  /// 加载事件数据，返回事件列表
  Future<List<Map<String, dynamic>>> loadSpends() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSpends = prefs.getString('Spends'); // 获取存储中的事件数据

    if (jsonSpends == null) {
      return []; // 如果事件数据不存在，返回空列表
    }

    // 解码存储的 JSON 数据，将其转换为 Dart 的 List 类型
    List<dynamic> decodedList = jsonDecode(jsonSpends);
    return decodedList
        .map((Spend) => Map<String, dynamic>.from(Spend)) // 转换每个事件为 Map 结构
        .toList(); 
  }

  /// 存储事件数据
  Future<void> saveSpends(List<Map<String, dynamic>> Spends) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonSpends = jsonEncode(Spends); // 将事件列表转换为 JSON 字符串
    await prefs.setString('Spends', jsonSpends); // 存储到 SharedPreferences
  }
}

*/

// 日历组件
class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _currentMonth = DateTime.now();  // 当前月份，初始化为当前时间
  DateTime _today = DateTime.now();  // 今天的日期
  double _horizontalDrag = 0.0;  // 记录水平滑动的距离
  late Future<List<Map<String, dynamic>>> _eventsFuture; // 存储事件的Future对象

  // 在初始化时加载事件
  @override
  void initState() {
    super.initState();
    _eventsFuture = EventStorage().loadEvents();  // 获取事件列表
  }

  // 计算给定月份的天数
  int _daysInMonth(DateTime month) {
    int nextMonth = month.month % 12 + 1;  // 获取下个月的月份，12月加1会变成1月
    int year = month.month == 12 ? month.year + 1 : month.year;  // 如果是12月，年份加1
    return DateTime(year, nextMonth, 1).subtract(Duration(days: 1)).day;  // 返回该月的最后一天的天数
  }

  // 计算该月第一天是星期几，返回偏移量（星期日为0，星期一为1，以此类推）
  int _firstDayOffset() {
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);  // 获取当前月的第一天
    return firstDay.weekday % 7;  // 将星期几转换为0-6的数字，星期日为0，星期一为1，以此类推
  }

  // 切换到上个月
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);  // 当前月份减去1，变成上个月
    });
  }

  // 切换到下个月
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);  // 当前月份加1，变成下个月
    });
  }

  // 处理滑动事件
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDrag += details.primaryDelta!;  // 累积滑动的距离
    });
  }

  // 处理滑动结束时的判断
  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_horizontalDrag > 50) {
      _previousMonth();  // 如果滑动距离大于50像素，切换到上个月
    } else if (_horizontalDrag < -50) {
      _nextMonth();  // 如果滑动距离小于-50像素，切换到下个月
    }
    setState(() {
      _horizontalDrag = 0.0;  // 重置滑动距离
    });
  }

void _showEventDetails(BuildContext context, int day, List<Map<String, dynamic>> eventsForDay) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '事件詳情：${DateFormat.yMMMd().format(
            DateTime(_currentMonth.year, _currentMonth.month, day),
          )}',
        ),
        content: eventsForDay.isEmpty
            ? Text('沒有事件')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: eventsForDay.map((event) {
                  bool isCompleted = event['completed'] ?? false; // 检查事件是否已完成
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '事件：${event['event_description']}，時間：${event['hour']}:${event['minute']}，重複：${event['repeat_option']}',
                      style: TextStyle(
                        fontSize: 14,
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none, // 如果事件已完成，加上删除线
                      ),
                    ),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
            child: Text('關閉'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,  // 处理滑动更新
      onHorizontalDragEnd: _onHorizontalDragEnd,  // 处理滑动结束
      child: Column(
        children: [
          // 显示月份和年份
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 左箭头按钮，用于切换到上个月
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: _previousMonth,  // 按钮点击时执行 _previousMonth 方法
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  DateFormat.yMMM().format(_currentMonth),  // 显示当前月份和年份，格式为 "yyyy MMM"
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // 右箭头按钮，用于切换到下个月
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: _nextMonth,  // 按钮点击时执行 _nextMonth 方法
              ),
            ],
          ),

          // 显示星期名称（Sun, Mon, Tue, ...）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekdays.map((weekday) {
                return Expanded(
                  child: Center(
                    child: Text(
                      weekday,  // 显示每一周的星期名称
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 使用 FutureBuilder 来显示事件
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _eventsFuture,  // 加载事件数据
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());  // 显示加载动画
                }

                if (snapshot.hasError) {
                  return Center(child: Text('加載錯誤！'));  // 显示错误信息
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('沒有事件'));  // 如果没有事件，显示提示
                }

                List<Map<String, dynamic>> events = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,  // 每行显示7天
                    childAspectRatio: 0.61,  // 设置格子的宽高比
                  ),
                  itemCount: _daysInMonth(_currentMonth) + _firstDayOffset(),
                  itemBuilder: (context, index) {
                    int day = index - _firstDayOffset() + 1;
                    if (day <= 0 || day > _daysInMonth(_currentMonth)) {
                      return Container();  // 超出当前月的日期显示为空
                    }

                    // 获取当天的事件
                    List<Map<String, dynamic>> eventsForDay = events.where((event) {
                      return event['day'] == day &&
                          event['month'] == _currentMonth.month &&
                          event['year'] == _currentMonth.year;
                    }).toList();

                    bool isToday = _today.year == _currentMonth.year &&
                        _today.month == _currentMonth.month &&
                        _today.day == day;

                    return GestureDetector(
                      onTap: () => _showEventDetails(context, day, eventsForDay),  // 点击日期时显示事件详情
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isToday ? Colors.white : Colors.black,
                              ),
                            ),
                            // 如果当天有事件，则显示事件数量
                            if (eventsForDay.isNotEmpty)
                              Icon(Icons.event, size: 16, color: isToday ? Colors.white : Colors.black),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 星期名称
  List<String> get _weekdays => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Flutter Calendar')),
      body: CalendarWidget(),
    ),
  ));
}