import 'package:flutter/material.dart';
import 'package:project2/Page/IconPage/IconAddSpendPage.dart'; // 引入 IconAddSpend 頁面
import 'package:project2/Tool/HomeDownButton.dart'; // 引入自定義底部按鈕
import 'package:project2/Storage/SpendStorage.dart'; // 引入 SpendStorage 類

class IconWallet extends StatefulWidget {
  @override
  _IconWalletState createState() => _IconWalletState();
}

class _IconWalletState extends State<IconWallet> {
  final SpendStorage _spendStorage = SpendStorage();
  List<Map<String, dynamic>> _spends = [];

  @override
  void initState() {
    super.initState();
    _loadSpends();
  }

  // 載入花費資料
  Future<void> _loadSpends() async {
    List<Map<String, dynamic>> spends = await _spendStorage.loadSpend();
    setState(() {
      _spends = spends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 底部導航欄
      appBar: AppBar(
        title: Text('所有花費記錄'), // 頁面標題
      ),
      body: _spends.isEmpty
          ? Center(child: Text('沒有花費記錄')) // 沒有資料時顯示的提示
          : ListView.builder(
              itemCount: _spends.length,
              itemBuilder: (context, index) {
                var spend = _spends[index];
                String spendTime = '${spend['year']}-${spend['month']}-${spend['day']} ${spend['hour']}:${spend['minute']}';
                return ListTile(
                  title: Text(spend['spend_description']),
                  subtitle: Text('時間: $spendTime\n類型: ${spend['spend_option']}\n金額: ${spend['spend_amount']}'), // 顯示金額
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
