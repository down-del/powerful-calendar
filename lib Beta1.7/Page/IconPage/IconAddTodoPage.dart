import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 套件用於格式化日期和時間
import 'package:calender/Page/HomePage.dart';
import 'package:calender/Page/IconPage/IconCheckBoxPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 元件（底部按鈕）
import 'dart:convert'; // 引入 json 套件用於序列化和反序列化資料

class EventStorage {
  // 儲存多個事件資料的方法
  Future<void> saveEvent({
    required int year, // 事件的年份
    required int month, // 事件的月份
    required int day, // 事件的日期
    required int hour, // 事件的小時
    required int minute, // 事件的分鐘
    required String eventDescription, // 事件的描述
    required String repeatOption, // 事件的重複選項
  }) async {
    final prefs = await SharedPreferences
        .getInstance(); // 獲取 SharedPreferences 實例，用於持久化儲存
    List<Map<String, dynamic>> events =
        await loadEvents(); // 獲取當前已儲存的事件清單，如果沒有則返回空清單

    // 建立一個新的事件資料，使用 Map 結構，新增 completed 欄位並預設為 false
    Map<String, dynamic> newEvent = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'event_description': eventDescription,
      'repeat_option': repeatOption,
      'completed': false, // 新增欄位，預設值為 false
    };

    // 將新的事件加入到現有的事件清單中
    events.add(newEvent);

    // 對事件清單按照時間順序進行排序
    events.sort((a, b) {
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB); // 升序排列
    });

    // 將事件清單轉換為 JSON 字串，方便儲存
    String jsonEvents = jsonEncode(events);

    // 將 JSON 字串儲存到 SharedPreferences 中
    await prefs.setString('events', jsonEvents);
  }

  // 從 SharedPreferences 載入所有事件資料
  Future<List<Map<String, dynamic>>> loadEvents() async {
    final prefs =
        await SharedPreferences.getInstance(); // 獲取 SharedPreferences 實例
    String? jsonEvents = prefs.getString('events'); // 獲取儲存的事件清單 JSON 字串

    if (jsonEvents == null) {
      return []; // 如果沒有儲存任何事件，返回空清單
    }

    // 將 JSON 字串反序列化為 List<Map<String, dynamic>> 類型
    List<dynamic> decodedList = jsonDecode(jsonEvents);

    // 將解碼後的 List<dynamic> 轉換為 List<Map<String, dynamic>>
    // 並確保資料類型正確
    return decodedList
        .map((event) => Map<String, dynamic>.from(event))
        .toList();
  }
}

// 這是一個 StatefulWidget，表示可以修改狀態的頁面
class IconAddTodo extends StatefulWidget {
  @override
  _IconAddTodoState createState() => _IconAddTodoState(); // 建立與此頁面相關聯的狀態
}

class _IconAddTodoState extends State<IconAddTodo> {
  // 初始化年、月、日、時、分，預設值是當前時間
  int year = DateTime.now().year; // 獲取當前年份
  int month = DateTime.now().month; // 獲取當前月份
  int day = DateTime.now().day; // 獲取當前日期
  int hour = DateTime.now().hour; // 獲取當前小時
  int minute = DateTime.now().minute; // 獲取當前分鐘

  final TextEditingController _eventController =
      TextEditingController(); // 控制事件描述輸入框的控制器

  String repeatOption = '一天一次'; // 預設的重複選項，表示事件每一天重複一次

  final EventStorage _eventStorage =
      EventStorage(); // 建立 EventStorage 實例，用於儲存和載入事件資料

  // 初始化時，呼叫 _loadEvents 方法從 EventStorage 中讀取已儲存的資料
  @override
  void initState() {
    super.initState();
    _loadEvents(); // 載入先前儲存的事件資料
  }

  // 非同步載入已儲存的事件
  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> events =
        await _eventStorage.loadEvents(); // 獲取已儲存的事件資料
    print('載入的事件: $events'); // 輸出事件清單，便於除錯
  }

  @override
  Widget build(BuildContext context) {
    // 獲取當前主題的亮度，用於判斷是否為深色模式
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      // 使用 Scaffold 來構建頁面
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39)
          : const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: HomeDownButton(), // 頁面底部按鈕，使用自訂元件
      appBar: AppBar(
        title: Text(
          '新增待辦事項',
          style: TextStyle(
            color: isDarkMode
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(255, 0, 0, 0),
          ),
        ), // 顯示在 AppBar 上的標題
        backgroundColor: isDarkMode // 設置 AppBar 的背景顏色
            ? const Color.fromARGB(255, 39, 39, 39)
            : const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // 設定內邊距，使內容更整齊
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 設定內容對齊方式為左對齊
          children: [
            // 顯示選擇日期的按鈕，點擊後會觸發日期選擇的功能
            GestureDetector(
              onTap: () => _selectDate(context), // 點擊後觸發 _selectDate 函數，選擇日期
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0), // 設定按鈕內部的邊距
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // 設定背景顏色為藍色
                  borderRadius: BorderRadius.circular(12), // 設定圓角
                ),
                child: Text(
                  '選擇日期: $formattedDate', // 顯示選擇的日期，使用 formattedDate 來格式化日期
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // 設定文字樣式
                ),
              ),
            ),
            SizedBox(height: 20), // 設定日期與時間區塊之間的間距

            // 顯示選擇時間的文字，顯示當前選擇的時間
            Text('選擇時間: $formattedTime',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 251, 251, 251)
                        : const Color.fromARGB(255, 0, 0, 0))),
            SizedBox(height: 20), // 設定時間與事件描述區塊之間的間距

            // 時間選擇的元件，使用 CupertinoPicker 實現上下滑動選擇
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 水平置中
              children: [
                // 選擇小時
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: hour), // 初始值為當前小時
                    itemExtent: 32, // 每一項的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        hour = index; // 更新選擇的小時
                      });
                    },
                    children: List<Widget>.generate(
                      24,
                      (int index) => Center(
                          child: Text('$index',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 242, 239, 239)
                                    : const Color.fromARGB(255, 12, 12, 12),
                              ))), // 生成 0 到 23 小時
                    ),
                  ),
                ),
                // 選擇分鐘
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: minute), // 初始值為當前分鐘
                    itemExtent: 32, // 每一項的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        minute = index; // 更新選擇的分鐘
                      });
                    },
                    children: List<Widget>.generate(
                      60,
                      (int index) => Center(
                          child: Text('$index',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 242, 239, 239)
                                    : const Color.fromARGB(255, 12, 12, 12),
                              ))), // 生成 0 到 59 分鐘
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 設定選擇時間區塊與事件描述輸入框之間的間距

            // 事件描述輸入框
            TextField(
              controller: _eventController,
              style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255) // 暗模式下的文字顏色
                    : Colors.black, // 亮模式下的文字顏色
              ),
              maxLength: 50, // 限制描述字數最多 50
              decoration: InputDecoration(
                labelText: '事件描述',
                border: OutlineInputBorder(), // 設定邊框樣式4
                labelStyle: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 242, 239, 239)
                        : const Color.fromARGB(255, 12, 12, 12)),
              ),
            ),
            SizedBox(height: 20),

            // 建立事件按鈕
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? const Color.fromARGB(255, 97, 97, 97)
                    : const Color.fromARGB(255, 212, 211, 211),
              ), // 設置按鈕的背景顏色
              onPressed: () {
                _saveEvent(); // 點擊按鈕後執行儲存事件的邏輯
                Navigator.push(
                  context, // 當前的上下文
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(), // 返回首頁頁面
                  ),
                );
              },
              child: Text('新增事件',
                  style: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 252, 252, 252)
                        : const Color.fromARGB(255, 0, 0, 0),
                  )), // 按鈕上的文字
            ),
          ],
        ),
      ),
    );
  }

  // 顯示日期選擇器並更新選擇的日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(year, month, day), // 初始日期為目前日期
      firstDate: DateTime(2000), // 最早可選日期
      lastDate: DateTime(2101), // 最晚可選日期
    );

    if (selectedDate != null && selectedDate != DateTime(year, month, day)) {
      setState(() {
        year = selectedDate.year;
        month = selectedDate.month;
        day = selectedDate.day;
      });
    }
  }

  // 格式化日期
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(DateTime(year, month, day));
  }

  // 格式化時間
  String get formattedTime {
    return DateFormat('HH:mm').format(DateTime(year, month, day, hour, minute));
  }

  // 儲存事件
  Future<void> _saveEvent() async {
    String eventDescription = _eventController.text; // 取得事件描述文字
    await _eventStorage.saveEvent(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      eventDescription: eventDescription,
      repeatOption: repeatOption, // 設定重複選項
    );
  }
}
