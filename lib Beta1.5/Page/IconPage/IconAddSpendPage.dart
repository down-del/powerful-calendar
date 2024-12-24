import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 包用於格式化日期和時間
import 'package:calender/Page/HomePage.dart'; // 引入 HomePage 頁面
import 'package:calender/Page/IconPage/IconCheckBoxPage.dart'; // 引入 IconCheckBoxPage 頁面
import 'package:shared_preferences/shared_preferences.dart'; // 用於存儲和讀取本地數據
import '../../Tool/HomeDownButton.dart'; // 引入自定義的底部按鈕元件
import 'dart:convert'; // 引入 json 庫用於序列化和反序列化數據
import 'package:uuid/uuid.dart';


// 用於存儲和加載事件數據的類
class SpendStorage {
  // 存儲事件數據的方法
  Future<void> saveSpend({
    required int spendYear, // 事件的年份
    required int spendMonth, // 事件的月份
    required int spendDay, // 事件的日期
    required int spendHour, // 事件的小時
    required int spendMinute, // 事件的分鐘
    required String spendDescription, // 事件的描述
    required String spendOption, // 事件的消費類型
    required double spendAmount, // 新增：事件的花費金額
  }) async {
    // 獲取 SharedPreferences 實例，用於存儲數據
    final prefs = await SharedPreferences.getInstance();
    // 從 SharedPreferences 獲取當前的事件列表
    List<Map<String, dynamic>> Spend = await loadSpend();

    // 創建一個新的事件數據，使用 Map 結構，新增 completed 欄位並默認設置為 false
    Map<String, dynamic> newSpend = {
      'year': spendYear,
      'month': spendMonth,
      'day': spendDay,
      'hour': spendHour,
      'minute': spendMinute,
      'spend_description': spendDescription,
      'spend_option': spendOption,
      'spend_amount': spendAmount, // 新增花費金額欄位
    };

    // 將新的事件添加到現有的事件列表中
    Spend.add(newSpend);

    // 對事件列表按照時間順序進行排序
    Spend.sort((a, b) {
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB); // 升序排列
    });

    // 將事件列表轉化為 JSON 字符串，方便存儲
    String jsonSpends = jsonEncode(Spend);

    // 將 JSON 字符串存儲到 SharedPreferences 中
    await prefs.setString('Spend', jsonSpends);
  }

  // 從 SharedPreferences 加載所有事件數據的方法
  Future<List<Map<String, dynamic>>> loadSpend() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSpend = prefs.getString('Spend'); // 獲取存儲的事件列表 JSON 字符串

    if (jsonSpend == null) {
      return []; // 如果沒有保存任何事件，返回空列表
    }

    // 將 JSON 字符串反序列化為 List<Map<String, dynamic>> 類型
    List<dynamic> decodedList = jsonDecode(jsonSpend);

    // 將解碼後的 List<dynamic> 轉換為 List<Map<String, dynamic>> 並確保數據類型正確
    return decodedList
        .map((Spend) => Map<String, dynamic>.from(Spend))
        .toList();
  }
}

// StatefulWidget 用於創建一個可以修改狀態的頁面
class IconAddSpend extends StatefulWidget {
  @override
  _IconAddSpendState createState() => _IconAddSpendState(); // 創建與此頁面相關聯的狀態
}

class _IconAddSpendState extends State<IconAddSpend> {
  // 初始化年、月、日、時、分，默認值是當前時間
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = DateTime.now().hour;
  int minute = DateTime.now().minute;

  final TextEditingController _SpendController =
      TextEditingController(); // 控制事件描述輸入框的控制器

  String spendOption = '食'; // 默認的消費類型選項

  final SpendStorage _spendStorage =
      SpendStorage(); // 創建 SpendStorage 實例，用於保存和加載事件數據

  final TextEditingController _AmountController =
      TextEditingController(); // 新增：控制花費金額輸入框的控制器

  // 初始化時，調用 _loadSpends 方法從 SpendStorage 中讀取已保存的數據
  @override
  void initState() {
    super.initState();
    _loadSpends(); // 加載先前保存的事件數據
  }

  // 異步加載已保存的事件
  Future<void> _loadSpends() async {
    List<Map<String, dynamic>> Spends = await _spendStorage.loadSpend();
    print('加載事件: $Spends'); // 輸出事件列表，便於調試
  }

  @override
  Widget build(BuildContext context) {
    // 獲取當前主題的亮度，用於設置底部按鈕的顏色
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39)
          : const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: HomeDownButton(), // 頁面底部按鈕，使用自定義元件
      appBar: AppBar(
        title: Text(
          '新增消費',
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
        padding: const EdgeInsets.all(16.0), // 設置內邊距，使內容更整齊
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 設置內容對齊方式為左對齊
          children: [
            // 顯示選擇日期的按鈕，點擊後會觸發日期選擇的功能
            GestureDetector(
              onTap: () => _selectDate(context), // 點擊後觸發 _selectDate 函數，選擇日期
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0), // 設置按鈕內部的邊距
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // 設置背景顏色為藍色
                  borderRadius: BorderRadius.circular(12), // 設置圓角
                ),
                child: Text(
                  '選擇日期: $formattedDate', // 顯示選擇的日期，使用 formattedDate 來格式化日期
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 251, 251, 251)
                        : const Color.fromARGB(255, 255, 255, 255), // 設置文字樣式
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 設置日期與時間區塊之間的間距

            // 顯示選擇時間的文字，顯示當前選擇的時間
            Text('選擇時間: $formattedTime',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 251, 251, 251)
                        : const Color.fromARGB(255, 0, 0, 0))), // 設置文字樣式
            SizedBox(height: 20), // 設置時間與事件描述區塊之間的間距

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
                        (int index) => Center(
                                child: Text(
                              '$index',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 242, 239, 239)
                                    : const Color.fromARGB(255, 12, 12, 12),
                              ),
                            ))), // 生成 0 到 23 小時
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
                                )))), // 生成 0 到 59 分鐘
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 設置選擇時間區塊與事件描述輸入框之間的間距

            // 事件描述輸入框
            TextField(
              controller: _SpendController, // 與事件描述的控制器綁定
              style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255) // 暗模式下的文字顏色
                    : Colors.black, // 亮模式下的文字顏色
              ),
              decoration: InputDecoration(
                  labelText: '消費描述',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 250, 250, 250)
                        : const Color.fromARGB(255, 0, 0, 0),
                  )), // 設置輸入框樣式
            ),
            SizedBox(height: 20), // 設置輸入框與選擇類別按鈕之間的間距

            // 花費金額輸入框
            TextField(
              controller: _AmountController, // 與金額輸入框的控制器綁定
              style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255) // 暗模式下的文字顏色
                    : Colors.black, // 亮模式下的文字顏色
              ),
              keyboardType: TextInputType.number, // 設置為數字輸入類型
              decoration: InputDecoration(
                  labelText: '消費金額',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 250, 250, 250)
                        : const Color.fromARGB(255, 0, 0, 0),
                  )), // 設置輸入框樣式
            ),

            SizedBox(height: 20), // 設置消費類別選擇與花費金額輸入框之間的間距

            // 選擇消費類別的下拉框
            DropdownButton<String>(
              value: spendOption, // 當前選擇的消費類別
              dropdownColor: isDarkMode
                  ? const Color.fromARGB(255, 39, 39, 39)
                  : const Color.fromARGB(255, 255, 255, 255), // 設置下拉框的背景顏色
              onChanged: (String? newValue) {
                setState(() {
                  spendOption = newValue!; // 更新選擇的消費類別
                });
              },
              items: <String>['食', '衣', '住', '行', '育', '樂', '其他'] // 可選類別
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 242, 239, 239)
                          : const Color.fromARGB(255, 12, 12, 12),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20), // 設置金額輸入框與新增事件按鈕之間的間距

            // 新增事件按鈕
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? const Color.fromARGB(255, 97, 97, 97)
                    : const Color.fromARGB(255, 212, 211, 211),
              ), // 設置按鈕的背景顏色
              onPressed: () async {
                double spendAmount = double.tryParse(_AmountController.text) ??
                    0.0; // 獲取用戶輸入的金額，默認值為 0.0
                await _spendStorage.saveSpend(
                  spendYear: year,
                  spendMonth: month,
                  spendDay: day,
                  spendHour: hour,
                  spendMinute: minute,
                  spendDescription: _SpendController.text, // 獲取事件描述
                  spendOption: spendOption, // 獲取消費類別
                  spendAmount: spendAmount, // 保存花費金額
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(), // 保存後跳轉到首頁
                  ),
                );
              },
              child: Text(
                '新增消費',
                style: TextStyle(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 252, 252, 252)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              ), // 按鈕文本
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
    return DateFormat('yyyy-MM-dd')
        .format(DateTime(year, month, day)); // 格式化日期為 yyyy-MM-dd
  }

  // 獲取格式化後的時間
  String get formattedTime {
    return DateFormat('HH:mm')
        .format(DateTime(year, month, day, hour, minute)); // 格式化時間為 HH:mm
  }
}
