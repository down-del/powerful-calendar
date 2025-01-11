import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 事件儲存管理類，負責加載和儲存事件數據
class EventStorage {
  /// 加載事件數據，返回事件列表
  Future<List<Map<String, dynamic>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonEvents = prefs.getString('events'); // 獲取儲存中的事件數據

    if (jsonEvents == null) {
      return []; // 如果事件數據不存在，返回空列表
    }

    // 解碼儲存的 JSON 數據，將其轉換為 Dart 的 List 類型
    List<dynamic> decodedList = jsonDecode(jsonEvents);
    return decodedList
        .map((event) => Map<String, dynamic>.from(event)) // 轉換每個事件為 Map 結構
        .toList();
  }

  /// 儲存事件數據
  Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonEvents = jsonEncode(events); // 將事件列表轉換為 JSON 字符串
    await prefs.setString('events', jsonEvents); // 儲存到 SharedPreferences
  }
}

/*暫時先不開發這部分

/// 事件儲存管理類，負責加載和儲存消費數據
class SpendStorage {
  /// 加載事件數據，返回事件列表
  Future<List<Map<String, dynamic>>> loadSpends() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSpends = prefs.getString('Spends'); // 獲取儲存中的事件數據

    if (jsonSpends == null) {
      return []; // 如果事件數據不存在，返回空列表
    }

    // 解碼儲存的 JSON 數據，將其轉換為 Dart 的 List 類型
    List<dynamic> decodedList = jsonDecode(jsonSpends);
    return decodedList
        .map((Spend) => Map<String, dynamic>.from(Spend)) // 轉換每個事件為 Map 結構
        .toList(); 
  }

  /// 儲存事件數據
  Future<void> saveSpends(List<Map<String, dynamic>> Spends) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonSpends = jsonEncode(Spends); // 將事件列表轉換為 JSON 字符串
    await prefs.setString('Spends', jsonSpends); // 儲存到 SharedPreferences
  }
}

*/

// 日曆組件
class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _currentMonth = DateTime.now(); // 當前月份，初始化為當前時間
  DateTime _today = DateTime.now(); // 今天的日期
  double _horizontalDrag = 0.0; // 記錄水平滑動的距離
  late Future<List<Map<String, dynamic>>> _eventsFuture; // 儲存事件的Future物件

  // 在初始化時加載事件
  @override
  void initState() {
    super.initState();
    _eventsFuture = EventStorage().loadEvents(); // 獲取事件列表
  }

  // 計算給定月份的天數
  int _daysInMonth(DateTime month) {
    int nextMonth = month.month % 12 + 1; // 獲取下個月的月份，12月加1會變成1月
    int year = month.month == 12 ? month.year + 1 : month.year; // 如果是12月，年份加1
    return DateTime(year, nextMonth, 1)
        .subtract(Duration(days: 1))
        .day; // 返回該月的最後一天的天數
  }

  // 計算該月第一天是星期幾，返回偏移量（星期日為0，星期一為1，以此類推）
  int _firstDayOffset() {
    DateTime firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1); // 獲取當前月的第一天
    return firstDay.weekday % 7; // 將星期幾轉換為0-6的數字，星期日為0，星期一為1，以此類推
  }

  // 切換到上個月
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
          _currentMonth.year, _currentMonth.month - 1); // 當前月份減去1，變成上個月
    });
  }

  // 切換到下個月
  void _nextMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1); // 當前月份加1，變成下個月
    });
  }

  // 處理滑動事件
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDrag += details.primaryDelta!; // 累積滑動的距離
    });
  }

  // 處理滑動結束時的判斷
  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_horizontalDrag > 50) {
      _previousMonth(); // 如果滑動距離大於50像素，切換到上個月
    } else if (_horizontalDrag < -50) {
      _nextMonth(); // 如果滑動距離小於-50像素，切換到下個月
    }
    setState(() {
      _horizontalDrag = 0.0; // 重置滑動距離
    });
  }

  void _showEventDetails(
      BuildContext context, int day, List<Map<String, dynamic>> eventsForDay) {
    // 檢查當前的亮暗色模式
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //對話框背景色
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 39, 39, 39)
              : const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            '事件詳情：${DateFormat.yMMMd().format(
              DateTime(_currentMonth.year, _currentMonth.month, day),
            )}',
            style: TextStyle(
              color: isDarkMode
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.black,
            ),
          ),
          content: eventsForDay.isEmpty
              ? Text(
                  '沒有事件',
                  style: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : Colors.black,
                  ),
                )
              : SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    // 加入 SingleChildScrollView 使內容可滾動
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eventsForDay.map((event) {
                        bool isCompleted =
                            event['completed'] ?? false; // 檢查事件是否已完成
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '事件：${event['event_description']}，時間：${event['hour']}:${event['minute']}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none, // 如果事件已完成，加上刪除線
                              decorationColor: isDarkMode
                                  ? Colors.white
                                  : isCompleted
                                      ? Colors.white
                                      : Colors.black,
                              decorationThickness: 2.5,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : Colors.black, // 設置事件描述顏色
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
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
    // 檢查當前的亮暗色模式
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate, // 處理滑動更新
        onHorizontalDragEnd: _onHorizontalDragEnd, // 處理滑動結束
        child: Container(
          // 設置背景色
          color: isDarkMode
              ? const Color.fromARGB(255, 39, 39, 39)
              : const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              // 顯示月份和年份
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 左箭頭按鈕，用於切換到上個月
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(
                          Icons.arrow_left,
                          //設置按鈕顏色
                          color: isDarkMode
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.black,
                        ),
                        onPressed: _previousMonth, // 按鈕點擊時執行 _previousMonth 方法
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Builder(
                      builder: (context) {
                        return Text(
                          DateFormat.yMMM().format(
                              _currentMonth), // 顯示當前月份和年份，格式為 "yyyy MMM"
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            //設置標題年月顏色
                            color: isDarkMode
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                  // 右箭頭按鈕，用於切換到下個月
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(
                          Icons.arrow_right,
                          //設置按鈕顏色
                          color: isDarkMode
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.black,
                        ),
                        onPressed: _nextMonth, // 按鈕點擊時執行 _nextMonth 方法
                      );
                    },
                  ),
                ],
              ),

              // 顯示星期名稱（Sun, Mon, Tue, ...）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _weekdays.map((weekday) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          weekday, // 顯示每一周的星期名稱
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            //設置星期名稱顏色
                            color: isDarkMode
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 使用 FutureBuilder 來顯示事件
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _eventsFuture, // 加載事件數據
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator()); // 顯示加載動畫
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('加載錯誤！')); // 顯示錯誤信息
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('沒有事件')); // 如果沒有事件，顯示提示
                    }

                    List<Map<String, dynamic>> events = snapshot.data!;

                    return CustomScrollView(
                      // 使用 CustomScrollView 讓頁面內容能夠垂直滾動
                      slivers: [
                        // SliverGrid 是一個可以讓內容網格化的滾動組件
                        SliverGrid(
                          // gridDelegate 決定了每一行的佈局和格子的大小
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, // 每行顯示 7 個格子，表示一周的 7 天
                            childAspectRatio:
                                0.62, // 設置每個格子的寬高比，0.62 讓格子更為接近正方形
                            mainAxisSpacing: 8, // 每個格子之間的垂直間距
                            crossAxisSpacing: 6.5, // 每個格子之間的水平間距
                          ),
                          // SliverChildBuilderDelegate 是一個生成網格子項的代理
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              // 計算當前格子的日期
                              int day = index - _firstDayOffset() + 1;

                              // 如果 day <= 0 或 day > 當前月份的天數，說明該格子是空的
                              if (day <= 0 ||
                                  day > _daysInMonth(_currentMonth)) {
                                return SizedBox.shrink(); // 返回一個空的空間占位符
                              }

                              // 獲取當天的事件
                              List<Map<String, dynamic>> eventsForDay =
                                  events.where((event) {
                                return event['day'] == day &&
                                    event['month'] == _currentMonth.month &&
                                    event['year'] == _currentMonth.year;
                              }).toList();

                              // 檢查今天的日期
                              bool isToday =
                                  _today.year == _currentMonth.year &&
                                      _today.month == _currentMonth.month &&
                                      _today.day == day;

                              // 返回每個日期格子的內容
                              return GestureDetector(
                                onTap: () => _showEventDetails(
                                  context,
                                  day,
                                  eventsForDay,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    // 檢查當前的亮暗色模式
                                    var brightness = MediaQuery.of(context)
                                        .platformBrightness;
                                    bool isDarkMode =
                                        brightness == Brightness.dark;
                                    return Container(
                                      decoration: BoxDecoration(
                                        //設置日期格子的背景色
                                        color: isToday
                                            ? (isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 255, 223, 16)
                                                : Colors.blue) // 根據暗色模式調整背景色
                                            : (isDarkMode
                                                ? const Color.fromARGB(
                                                    241, 38, 36, 36)
                                                : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255)), // 根據暗色模式調整其他日期背景色
                                        borderRadius:
                                            BorderRadius.circular(8.0), // 圓角邊框
                                      ),
                                      child: Column(
                                        children: [
                                          // 顯示日期
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text(
                                              '$day', // 顯示日期數字
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                //設置日期顏色
                                                color: isToday
                                                    ? (isDarkMode
                                                        ? const Color.fromARGB(
                                                            255, 255, 255, 255)
                                                        : const Color.fromARGB(
                                                            255,
                                                            252,
                                                            253,
                                                            253)) // 根據暗色模式調整背景色
                                                    : (isDarkMode
                                                        ? const Color.fromARGB(
                                                            255, 255, 255, 255)
                                                        : const Color.fromARGB(
                                                            255,
                                                            0,
                                                            0,
                                                            0)), // 根據暗色模式調整其他日期背景色
                                              ),
                                            ),
                                          ),

                                          // 顯示當天的事件數量
                                          if (eventsForDay.isNotEmpty)
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: eventsForDay.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  Map<String, dynamic> event =
                                                      eventsForDay[index];
                                                  bool isCompleted =
                                                      event['completed'] ??
                                                          false; // 檢查事件是否已完成
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    child: Text(
                                                      '${event['event_description']}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        decorationThickness:
                                                            2.5,
                                                        decoration: isCompleted
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none, // 如果事件已完成，加上刪除線
                                                        //設置删除線顏色
                                                        decorationColor:
                                                            isDarkMode
                                                                ? Colors.white
                                                                : isToday
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                        //設置事件描述顏色
                                                        color: isToday
                                                            ? (isDarkMode
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    247,
                                                                    247,
                                                                    247))
                                                            : (isDarkMode
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    0,
                                                                    0,
                                                                    0)),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: _daysInMonth(_currentMonth) +
                                _firstDayOffset(), // 總格子數量 = 當月天數 + 當月第一天偏移量
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

// 星期名稱的靜態列表
final List<String> _weekdays = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat'
];

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Flutter Calendar')),
      body: CalendarWidget(),
    ),
  ));
}
