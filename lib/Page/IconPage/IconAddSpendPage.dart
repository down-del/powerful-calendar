import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 包用于格式化日期和时间
import 'package:calender/Page/HomePage.dart'; // 引入 HomePage 页面
import 'package:calender/Page/IconPage/IconCheckBoxPage.dart'; // 引入 IconCheckBoxPage 页面
import 'package:shared_preferences/shared_preferences.dart'; // 用于存储和读取本地数据
import '../../Tool/HomeDownButton.dart'; // 引入自定义的底部按钮组件
import 'dart:convert'; // 引入 json 库用于序列化和反序列化数据

// 用于存储和加载事件数据的类
class SpendStorage {
  // 存储事件数据的方法
  Future<void> saveSpend({
    required int spendYear, // 事件的年份
    required int spendMonth, // 事件的月份
    required int spendDay, // 事件的日期
    required int spendHour, // 事件的小时
    required int spendMinute, // 事件的分钟
    required String spendDescription, // 事件的描述
    required String spendOption, // 事件的消费类型
    required double spendAmount, // 新增：事件的花费金额
  }) async {
    // 获取 SharedPreferences 实例，用于存储数据
    final prefs = await SharedPreferences.getInstance();
    // 从 SharedPreferences 获取当前的事件列表
    List<Map<String, dynamic>> Spend = await loadSpend();

    // 创建一个新的事件数据，使用 Map 结构，新增 completed 字段并默认设置为 false
    Map<String, dynamic> newSpend = {
      'year': spendYear,
      'month': spendMonth,
      'day': spendDay,
      'hour': spendHour,
      'minute': spendMinute,
      'spend_description': spendDescription,
      'spend_option': spendOption,
      'spend_amount': spendAmount, // 新增花费金额字段
    };

    // 将新的事件添加到现有的事件列表中
    Spend.add(newSpend);

    // 对事件列表按照时间顺序进行排序
    Spend.sort((a, b) {
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB); // 升序排列
    });

    // 将事件列表转化为 JSON 字符串，方便存储
    String jsonSpends = jsonEncode(Spend);

    // 将 JSON 字符串存储到 SharedPreferences 中
    await prefs.setString('Spend', jsonSpends);
  }

  // 从 SharedPreferences 加载所有事件数据的方法
  Future<List<Map<String, dynamic>>> loadSpend() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSpend = prefs.getString('Spend'); // 获取存储的事件列表 JSON 字符串

    if (jsonSpend == null) {
      return []; // 如果没有保存任何事件，返回空列表
    }

    // 将 JSON 字符串反序列化为 List<Map<String, dynamic>> 类型
    List<dynamic> decodedList = jsonDecode(jsonSpend);

    // 将解码后的 List<dynamic> 转换为 List<Map<String, dynamic>> 并确保数据类型正确
    return decodedList
        .map((Spend) => Map<String, dynamic>.from(Spend))
        .toList();
  }
}

// StatefulWidget 用于创建一个可以修改状态的页面
class IconAddSpend extends StatefulWidget {
  @override
  _IconAddSpendState createState() => _IconAddSpendState(); // 创建与此页面相关联的状态
}

class _IconAddSpendState extends State<IconAddSpend> {
  // 初始化年、月、日、时、分，默认值是当前时间
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = DateTime.now().hour;
  int minute = DateTime.now().minute;

  final TextEditingController _SpendController =
      TextEditingController(); // 控制事件描述输入框的控制器

  String spendOption = '食'; // 默认的消费类型选项

  final SpendStorage _spendStorage =
      SpendStorage(); // 创建 SpendStorage 实例，用于保存和加载事件数据

  final TextEditingController _AmountController = TextEditingController(); // 新增：控制花费金额输入框的控制器

  // 初始化时，调用 _loadSpends 方法从 SpendStorage 中读取已保存的数据
  @override
  void initState() {
    super.initState();
    _loadSpends(); // 加载先前保存的事件数据
  }

  // 异步加载已保存的事件
  Future<void> _loadSpends() async {
    List<Map<String, dynamic>> Spends = await _spendStorage.loadSpend();
    print('加載事件: $Spends'); // 输出事件列表，便于调试
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 页面底部按钮，使用自定义组件
      appBar: AppBar(
        title: Text('新增消費'), // 显示在 AppBar 上的标题
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // 设置内边距，使内容更整齐
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 设置内容对齐方式为左对齐
          children: [
            // 显示选择日期的按钮，点击后会触发日期选择的功能
            GestureDetector(
              onTap: () => _selectDate(context), // 点击后触发 _selectDate 函数，选择日期
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0), // 设置按钮内部的边距
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // 设置背景颜色为蓝色
                  borderRadius: BorderRadius.circular(12), // 设置圆角
                ),
                child: Text(
                  '選擇日期: $formattedDate', // 显示选择的日期，使用 formattedDate 来格式化日期
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 设置文字样式
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 设置日期与时间区块之间的间距

            // 显示选择时间的文字，显示当前选择的时间
            Text('選擇時間: $formattedTime',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20), // 设置时间与事件描述区块之间的间距

            // 时间选择的组件，使用 CupertinoPicker 实现上下滑动选择
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 水平居中
              children: [
                // 选择小时
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: hour), // 初始值为当前小时
                    itemExtent: 32, // 每一项的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        hour = index; // 更新选择的小时
                      });
                    },
                    children: List<Widget>.generate(
                        24,
                        (int index) =>
                            Center(child: Text('$index'))), // 生成 0 到 23 小时
                  ),
                ),
                // 选择分钟
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: minute), // 初始值为当前分钟
                    itemExtent: 32, // 每一项的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        minute = index; // 更新选择的分钟
                      });
                    },
                    children: List<Widget>.generate(
                        60,
                        (int index) =>
                            Center(child: Text('$index'))), // 生成 0 到 59 分钟
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 设置选择时间区块与事件描述输入框之间的间距

            // 事件描述输入框
            TextField(
              controller: _SpendController, // 与事件描述的控制器绑定
              decoration: InputDecoration(
                  labelText: '消費描述', border: OutlineInputBorder()), // 设置输入框样式
            ),
            SizedBox(height: 20), // 设置输入框与选择类别按钮之间的间距

            // 花费金额输入框
            TextField(
              controller: _AmountController, // 与金额输入框的控制器绑定
              keyboardType: TextInputType.number, // 设置为数字输入类型
              decoration: InputDecoration(
                  labelText: '消費金額', border: OutlineInputBorder()), // 设置输入框样式
            ),

            SizedBox(height: 20), // 设置消费类别选择与花费金额输入框之间的间距

            // 选择消费类别的下拉框
            DropdownButton<String>(
              value: spendOption, // 当前选择的消费类别
              onChanged: (String? newValue) {
                setState(() {
                  spendOption = newValue!; // 更新选择的消费类别
                });
              },
              items: <String>['食', '衣', '住', '行', '育', '樂', '其他'] // 可选类别
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            SizedBox(height: 20), // 设置金额输入框与新增事件按钮之间的间距

            

            // 新增事件按钮
            ElevatedButton(
              onPressed: () async {
                double spendAmount =
                    double.tryParse(_AmountController.text) ?? 0.0; // 获取用户输入的金额，默认值为 0.0
                await _spendStorage.saveSpend(
                  spendYear: year,
                  spendMonth: month,
                  spendDay: day,
                  spendHour: hour,
                  spendMinute: minute,
                  spendDescription: _SpendController.text, // 获取事件描述
                  spendOption: spendOption, // 获取消费类别
                  spendAmount: spendAmount, // 保存花费金额
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(), // 保存后跳转到首页
                  ),
                );
              },
              child: Text('新增消費'), // 按钮文本
            ),
          ],
        ),
      ),
    );
  }

  // 日期选择函数，点击日期时触发
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        year = picked.year; // 更新选择的年份
        month = picked.month; // 更新选择的月份
        day = picked.day; // 更新选择的日期
      });
    }
  }

  // 获取格式化后的日期
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(DateTime(year, month, day)); // 格式化日期为 yyyy-MM-dd
  }

  // 获取格式化后的时间
  String get formattedTime {
    return DateFormat('HH:mm').format(DateTime(year, month, day, hour, minute)); // 格式化时间为 HH:mm
  }
}
