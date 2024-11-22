import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入intl包進行日期格式化
import 'package:calender/Page/IconPage/IconAddIncomePage.dart';
import 'package:calender/Page/IconPage/IconAddSpendPage.dart';
import 'package:calender/Tool/HomeDownButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  DateTime _selectedDate = DateTime.now(); // 當前選擇的日期（默認為當前月份）
  List<Map<String, dynamic>> _incomeData = []; // 當月的收入數據
  List<Map<String, dynamic>> _expenseData = []; // 當月的支出數據
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

  // 加載收入和支出的數據，並計算結算金額
  Future<void> _loadData() async {
    List<Map<String, dynamic>> allIncome = await _incomeStorage.loadIcon();
    List<Map<String, dynamic>> allExpenses = await _expenseStorage.loadSpend();

    setState(() {
      // 篩選當月的收入與支出
      _incomeData = allIncome.where((item) {
        return item['year'] == _selectedDate.year &&
            item['month'] == _selectedDate.month;
      }).toList();

      _expenseData = allExpenses.where((item) {
        return item['year'] == _selectedDate.year &&
            item['month'] == _selectedDate.month;
      }).toList();

      // 計算當月結算金額
      _monthlyBalance = _incomeData.fold(0.0, (sum, item) {
        double amount = item['Icon_amount'] != null
            ? double.tryParse(item['Icon_amount'].toString()) ?? 0.0
            : 0.0;
        return sum + amount;
      }) - _expenseData.fold(0.0, (sum, item) {
        double amount = item['spend_amount'] != null
            ? double.tryParse(item['spend_amount'].toString()) ?? 0.0
            : 0.0;
        return sum + amount;
      });

      // 更新歷史總結算金額
      Global.historicalBalance = _monthlyBalance; // 儲存當月的結算金額為歷史總結算金額
    });
  }

  // 切換月份
  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
        1,
      );
    });
    _loadData(); // 更新數據
  }

  // 進入或退出選取模式
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear(); // 清空選中項目
    });
  }

  // 刪除選定項目
  Future<void> _deleteSelectedItems() async {
    if (_isSelectionMode) {
      // 刪除收入數據
      _incomeData.removeWhere((item) => _selectedItems.contains(item.hashCode));
      await _incomeStorage.saveIconList(_incomeData);

      // 刪除支出數據
      _expenseData
          .removeWhere((item) => _selectedItems.contains(item.hashCode));
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
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 页面底部按钮，使用自定义组件      
      appBar: AppBar(
        title: Text("Transactions"),
        actions: [
          // 顯示選取模式的圖示，按鈕可以進入或退出選取模式
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.check : Icons.delete),
            onPressed: _toggleSelectionMode, // 切換選取模式
          ),
        ],
      ),
      body: Column(
        children: [
          // 顯示年份與月份
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 向前切換月份
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _changeMonth(-1),
                ),
                // 顯示當前的年月
                Text(
                  "${_selectedDate.year} - ${_selectedDate.month.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // 向後切換月份
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          // 顯示收入與支出列表
          Expanded(
            child: ListView.builder(
              itemCount: _incomeData.length + _expenseData.length,
              itemBuilder: (context, index) {
                bool isIncome = index < _incomeData.length;
                Map<String, dynamic> item = isIncome
                    ? _incomeData[index]
                    : _expenseData[index - _incomeData.length];

                bool isSelected = _selectedItems.contains(item.hashCode);

                // 格式化日期，顯示為 yyyy年MM月dd日
                DateTime date = DateTime(item['year'], item['month'], item['day']);
                String formattedDate = DateFormat('yyyy年MM月dd日').format(date);

                return ListTile(
                  title: Text(
                    item[isIncome ? 'Icon_description' : 'spend_description'],
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    "${isIncome ? '+' : '-'}\$${item[isIncome ? 'Icon_amount' : 'spend_amount']}",
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  tileColor: isSelected ? Colors.grey[300] : null,
                  onTap: _isSelectionMode
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedItems.remove(item.hashCode);
                            } else {
                              _selectedItems.add(item.hashCode);
                            }
                          });
                        }
                      : null,
                );
              },
            ),
          ),
          // 顯示當月結算金額
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Monthly Balance: \$$_monthlyBalance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _monthlyBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
          // // 顯示歷史總結算金額
          // Container(
          //   padding: EdgeInsets.all(5.0),
          //   child: Text(
          //     "Historical Balance: \$${Global.historicalBalance.toStringAsFixed(2)}", // 顯示歷史總結算金額
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //       color: Global.historicalBalance >= 0 ? Colors.green : Colors.red,
          //     ),
          //   ),
          // ),
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
    await prefs.setString('Icon', jsonEncode(list));
  }
}

extension SpendExtensions on SpendStorage {
  Future<void> saveSpendList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Spend', jsonEncode(list));
  }
}
