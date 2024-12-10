import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 包用於格式化日期和時間
import 'package:calender/Page/HomePage.dart'; // 引入 HomePage 頁面
import 'package:calender/Page/IconPage/IconCheckBoxPage.dart'; // 引入 IconCheckBoxPage 頁面
import 'package:shared_preferences/shared_preferences.dart'; // 用於儲存和讀取本地資料
import '../../Tool/HomeDownButton.dart'; // 引入自訂的底部按鈕元件
import 'dart:convert'; // 引入 json 庫用於序列化和反序列化資料

// 用於儲存和加載事件資料的類別
class IconStorage {
  // 儲存事件資料的方法
  Future<void> saveIcon({
    required int iconYear, // 事件的年份
    required int iconMonth, // 事件的月份
    required int iconDay, // 事件的日期
    required int iconHour, // 事件的小時
    required int iconMinute, // 事件的分鐘
    required String IconDescription, // 收入的描述
    required double IconAmount, // 收入的金額
  }) async {
    // 獲取 SharedPreferences 實例，用於儲存資料
    final prefs = await SharedPreferences.getInstance();
    // 從 SharedPreferences 獲取當前的事件列表
    List<Map<String, dynamic>> Icon = await loadIcon();

    // 建立一個新的事件資料，使用 Map 結構，新增 completed 欄位並預設設定為 false
    Map<String, dynamic> newIcon = {
      'year': iconYear,
      'month': iconMonth,
      'day': iconDay,
      'hour': iconHour,
      'minute': iconMinute,
      'Icon_description': IconDescription,
      'Icon_amount': IconAmount, // 新增花費金額欄位
    };

    // 將新的事件添加到現有的事件列表中
    Icon.add(newIcon);

    // 對事件列表按照時間順序進行排序
    Icon.sort((a, b) {
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB); // 升序排列
    });

    // 將事件列表轉化為 JSON 字串，方便儲存
    String jsonIcons = jsonEncode(Icon);

    // 將 JSON 字串儲存到 SharedPreferences 中
    await prefs.setString('Icon', jsonIcons);
  }

  // 從 SharedPreferences 加載所有事件資料的方法
  Future<List<Map<String, dynamic>>> loadIcon() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonIcon = prefs.getString('Icon'); // 獲取儲存的事件列表 JSON 字串

    if (jsonIcon == null) {
      return []; // 如果沒有保存任何事件，返回空列表
    }

    // 將 JSON 字串反序列化為 List<Map<String, dynamic>> 類型
    List<dynamic> decodedList = jsonDecode(jsonIcon);

    // 將解碼後的 List<dynamic> 轉換為 List<Map<String, dynamic>> 並確保資料類型正確
    return decodedList
        .map((Icon) => Map<String, dynamic>.from(Icon))
        .toList();
  }
}

// StatefulWidget 用於建立一個可以修改狀態的頁面
class IconAddIncome extends StatefulWidget {
  @override
  _IconAddIncomeState createState() => _IconAddIncomeState(); // 建立與此頁面相關聯的狀態
}

class _IconAddIncomeState extends State<IconAddIncome> {
  // 初始化年、月、日、時、分，預設值是當前時間
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = DateTime.now().hour;
  int minute = DateTime.now().minute;

  final TextEditingController _IconController =
      TextEditingController(); // 控制事件描述輸入框的控制器

  final IconStorage _IconStorage =
      IconStorage(); // 建立 IconStorage 實例，用於儲存和加載事件資料

  final TextEditingController _AmountController = TextEditingController(); // 新增：控制花費金額輸入框的控制器

  // 初始化時，呼叫 _loadIcons 方法從 IconStorage 中讀取已保存的資料
  @override
  void initState() {
    super.initState();
    _loadIcons(); // 加載先前保存的事件資料
  }

  // 非同步加載已保存的事件
  Future<void> _loadIcons() async {
    List<Map<String, dynamic>> Icons = await _IconStorage.loadIcon();
    print('加載事件: $Icons'); // 輸出事件列表，便於除錯
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 頁面底部按鈕，使用自訂元件
      appBar: AppBar(
        title: Text('新增收入'), // 顯示在 AppBar 上的標題
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
                    color: Colors.white, // 設定文字樣式
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 設定日期與時間區塊之間的間距

            // 顯示選擇時間的文字，顯示當前選擇的時間
            Text('選擇時間: $formattedTime',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20), // 設定時間與事件描述區塊之間的間距

            // 時間選擇的元件，使用 CupertinoPicker 實現上下滑動選擇
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 水平居中
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
                        (int index) =>
                            Center(child: Text('$index'))), // 生成 0 到 23 小時
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
                        (int index) =>
                            Center(child: Text('$index'))), // 生成 0 到 59 分鐘
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 設定選擇時間區塊與事件描述輸入框之間的間距

            // 事件描述輸入框
            TextField(
              controller: _IconController, // 與事件描述的控制器綁定
              decoration: InputDecoration(
                  labelText: '收入描述', border: OutlineInputBorder()), // 設定輸入框樣式
            ),
            SizedBox(height: 20), // 設定輸入框與選擇類別按鈕之間的間距

            // 花費金額輸入框
            TextField(
              controller: _AmountController, // 與金額輸入框的控制器綁定
              keyboardType: TextInputType.number, // 設定為數字輸入類型
              decoration: InputDecoration(
                  labelText: '收入金額', border: OutlineInputBorder()), // 設定輸入框樣式
            ),
            SizedBox(height: 20), // 設定金額輸入框與新增事件按鈕之間的間距

            // 新增事件按鈕
            ElevatedButton(
              onPressed: () async {
                double IconAmount =
                    double.tryParse(_AmountController.text) ?? 0.0; // 獲取使用者輸入的金額，預設值為 0.0
                await _IconStorage.saveIcon(
                  iconYear: year,
                  iconMonth: month,
                  iconDay: day,
                  iconHour: hour,
                  iconMinute: minute,
                  IconDescription: _IconController.text, // 獲取事件描述
                  IconAmount: IconAmount, // 儲存花費金額
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(), // 儲存後跳轉到首頁
                  ),
                );
              },
              child: Text('新增收入'), // 按鈕文字
            ),
          ],
        ),
      ),
    );
  }

  // 日期選擇函數，點擊日期時觸發
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        year = picked.year; // 更新選擇的年份
        month = picked.month; // 更新選擇的月份
        day = picked.day; // 更新選擇的日期
      });
    }
  }

  // 獲取格式化後的日期
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(DateTime(year, month, day)); // 格式化日期為 yyyy-MM-dd
  }

  // 獲取格式化後的時間
  String get formattedTime {
    return DateFormat('HH:mm').format(DateTime(year, month, day, hour, minute)); // 格式化時間為 HH:mm
  }
}
