import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入intl包進行日期格式化
import 'package:calender/Page/IconPage/IconAddIncomePage.dart';
import 'package:calender/Page/IconPage/IconAddSpendPage.dart';
import 'package:calender/Tool/HomeDownButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

// 用於生成唯一的整數 ID
class IdGenerator {
  static int _currentId = 0;

  // 獲取並遞增 ID
  static int generateId() {
    return _currentId++;
  }
}

// 為每項數據添加唯一的 ID
void addIdToExistingData(List<Map<String, dynamic>> dataList) {
  for (var item in dataList) {
    if (!item.containsKey('id')) {
      // 如果當前項目沒有 id，生成一個新的唯一 ID
      item['id'] = IdGenerator.generateId(); // 為該項目生成唯一的 ID
    }
  }
}

// global.dart
class Global {
  static double historicalBalance = 0.0;
}

// 引入您已經創建的 IconStorage 和 SpendStorage 類
class IconWallet extends StatefulWidget {
  @override
  _IconWalletState createState() => _IconWalletState();
}

class _IconWalletState extends State<IconWallet> {
  double _horizontalDrag = 0.0; // 滑動的距離
  List<Map<String, dynamic>> _incomeData = []; // 所有的收入數據
  List<Map<String, dynamic>> _expenseData = []; // 所有的支出數據
  Set<int> _selectedItems = {}; // 選取模式下已選中的項目索引
  bool _isSelectionMode = false; // 是否處於選取模式

  double _monthlyBalance = 0; // 當月結算金額

  final _incomeStorage = IconStorage(); // 收入存儲類
  final _expenseStorage = SpendStorage(); // 支出存儲類

  @override
  void initState() {
    super.initState();
    _loadData(); // 初始化時加載數據
  }

  // 加載所有收入和支出的數據，並計算結算金額
  Future<void> _loadData() async {
    List<Map<String, dynamic>> allIncome = await _incomeStorage.loadIcon();
    List<Map<String, dynamic>> allExpenses = await _expenseStorage.loadSpend();

    // 給已有數據添加 ID
    addIdToExistingData(allIncome);
    addIdToExistingData(allExpenses);

    setState(() {
      // 直接將所有收入與支出顯示
      _incomeData = allIncome;
      _expenseData = allExpenses;

      // 計算所有結算金額
      _monthlyBalance = _incomeData.fold(0.0, (sum, item) {
        double amount = item['Icon_amount'] != null
            ? double.tryParse(item['Icon_amount'].toString()) ?? 0.0
            : 0.0;
        return sum + amount;
      }) - 
          _expenseData.fold(0.0, (sum, item) {
        double amount = item['spend_amount'] != null
            ? double.tryParse(item['spend_amount'].toString()) ?? 0.0
            : 0.0;
        return sum + amount;
      });

      // 更新歷史總結算金額
      Global.historicalBalance = _monthlyBalance; // 儲存當月的結算金額為歷史總結算金額
    });
  }

  // 進入或退出選取模式
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear(); // 清空選中項目
    });
  }

  // 刪除已選中的項目
  Future<void> _deleteSelectedItems() async {
    if (_isSelectionMode) {
      // 刪除收入數據
      _incomeData.removeWhere((item) {
        int itemId = int.tryParse(item['id'].toString()) ?? 0;
        bool shouldDelete = _selectedItems.contains(itemId);
        return shouldDelete;
      });
      await _incomeStorage.saveIconList(_incomeData);

      // 刪除支出數據
      _expenseData.removeWhere((item) {
        int itemId = int.tryParse(item['id'].toString()) ?? 0;
        bool shouldDelete = _selectedItems.contains(itemId);
        return shouldDelete;
      });
      await _expenseStorage.saveSpendList(_expenseData);

      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false; // 退出選取模式
      });

      _loadData(); // 更新數據
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark; // 判斷是否為深色模式
    return Scaffold(
      bottomNavigationBar: HomeDownButton(),
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39) // 深色模式背景顏色
          : const Color.fromARGB(255, 255, 255, 255), // 淺色模式背景顏色
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 39, 39, 39) // 深色模式AppBar顏色
            : const Color.fromARGB(255, 255, 255, 255), // 淺色模式AppBar顏色
        title: Text(
          "Transactions", // 頁面標題
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          // 顯示選取模式的圖示，按鈕可以進入或退出選取模式
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.check : Icons.delete,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: _toggleSelectionMode, // 切換選取模式
          ),
        ],
      ),
      body: Column(
        children: [
          // 顯示收入與支出列表
          Expanded(
            child: ListView.builder(
              itemCount: _incomeData.length + _expenseData.length, // 列表項目數量
              itemBuilder: (context, index) {
                bool isIncome = index < _incomeData.length; // 判斷當前項目是收入還是支出
                Map<String, dynamic> item = isIncome
                    ? _incomeData[index]
                    : _expenseData[index - _incomeData.length];

                bool isSelected = _selectedItems.contains(item['id']); // 判斷項目是否被選中

                // 格式化日期，顯示為 yyyy年MM月dd日
                DateTime date =
                    DateTime(item['year'], item['month'], item['day']);
                String formattedDate = DateFormat('yyyy年MM月dd日').format(date);

                // 顯示列表項目
                return ListTile(
                  title: Text(
                    item[isIncome ? 'Icon_description' : 'spend_description'],
                    style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  trailing: Text(
                    "${isIncome ? '+' : '-'}\$${item[isIncome ? 'Icon_amount' : 'spend_amount']}", // 顯示金額
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  tileColor: isSelected
                      ? const Color.fromARGB(255, 165, 79, 79) // 選中項目顏色
                      : null,
                  onTap: _isSelectionMode
                      ? () {
                          int itemId =
                              int.tryParse(item['id'].toString()) ?? 0;
                          setState(() {
                            if (_selectedItems.contains(itemId)) {
                              _selectedItems.remove(itemId); // 如果已經選中，則移除
                            } else {
                              _selectedItems.add(itemId); // 如果沒有選中，則添加
                            }
                          });
                        }
                      : null,
                );
              },
            ),
          ),
          // 顯示總結算金額
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Total Balance: \$$_monthlyBalance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _monthlyBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton(
              onPressed: _deleteSelectedItems, // 刪除選中項目
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }
}

// 用於保存列表的新方法
extension StorageExtensions on IconStorage {
  Future<void> saveIconList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Icon', jsonEncode(list)); // 將數據保存到SharedPreferences中
  }
}

extension SpendExtensions on SpendStorage {
  Future<void> saveSpendList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'Spend', jsonEncode(list)); // 將數據保存到SharedPreferences中
  }
}
