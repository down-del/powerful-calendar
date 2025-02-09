// homedownbutton.dart
import 'package:flutter/material.dart';
import 'package:calender/Page/IconPage/IconAddIncomePage.dart';
import '../Page/IconPage/IconAddTodoPage.dart';
import '../Page/IconPage/IconAddSpendPage.dart';
import '../Page/IconPage/IconCheckBoxPage.dart';
import '../Page/IconPage/IconSettings.dart';
import '../Page/IconPage/IconWalletPage.dart';
import '../Page/HomePage.dart';

class HomeDownButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, //MainAxisAlignment.spaceAround
        children: [
          IconButton(
            icon: Icon(Icons.home),
            iconSize: 35,
            onPressed: () {
              print('Home button clicked');
              Navigator.push(
                context, // 當前的上下文
                MaterialPageRoute(
                  // 使用 MaterialPageRoute 來跳轉的頁面
                  builder: (context) =>
                      MyHomePage(), // 當新的頁面需要顯示時，構建 MyHomePage()
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.check_box_outlined),
            iconSize: 35,
            onPressed: () {
              print('Add new item clicked');
              Navigator.push(
                context, // 當前的上下文
                MaterialPageRoute(
                  // 使用 MaterialPageRoute 來跳轉的頁面
                  builder: (context) =>
                      IconCheakBox(), // 當新的頁面需要顯示時，構建 IconCheakBox()
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            iconSize: 37,
            onPressed: () {
              showModalBottomSheet(
                context: context, // 傳入上下文
                isScrollControlled: true,// 使內容大小可控，避免過高的視窗遮住其他內容
                backgroundColor: Colors.transparent, // 背景透明
                builder: (BuildContext context) {
                  return Container(
                    height: 200, // 彈出視窗的高度
                    decoration: BoxDecoration(
                      color: Colors.white, // 背景色設為白色
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16), // 左上角圓角
                        topRight: Radius.circular(16), // 右上角圓角
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // 撑滿寬度
                      children: [
                        // 第一個選項
                        ListTile(
                          leading:
                              Icon(Icons.monetization_on_outlined, color: Colors.red), // 圖標
                          title: Text('新增花費'), // 標題
                          onTap: () {
                            Navigator.pop(context); // 關閉彈出視窗
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => IconAddSpend()),
                            );
                          },
                        ),
                        // 第二個選項
                        ListTile(
                          leading:
                              Icon(Icons.monetization_on_outlined, color: Colors.green), // 圖標
                          title: Text('新增收入'), // 標題
                          onTap: () {
                            Navigator.pop(context); // 關閉彈出視窗
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => IconAddIncome()),
                            );
                          },
                        ),
                        // 第三個選項
                        ListTile(
                          leading: Icon(Icons.event_note, color: const Color.fromARGB(255, 15, 227, 255)),
                          title: Text('新增待辦事項'),
                          onTap: () {
                            Navigator.pop(context); // 關閉彈出視窗
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => IconAddTodo()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
              // Navigator.push(
              //   context, // 當前的上下文
              //   MaterialPageRoute(
              //     // 使用 MaterialPageRoute 來創建一個新的頁面
              //     builder: (context) => IconAdd(), // 當新的頁面需要顯示時，構建 IconAdd()
              //   ),
              // );
              print('Add new item clicked');
            },
          ),
          IconButton(
            icon: Icon(Icons.wallet),
            iconSize: 35,
            onPressed: () {
              Navigator.push(
                context, // 當前的上下文
                MaterialPageRoute(
                  // 使用 MaterialPageRoute 來創建一個新的頁面
                  builder: (context) =>
                      IconWallet(), // 當新的頁面需要顯示時，構建 IconWallet()
                ),
              );
              print('Add new item clicked');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 35,
            onPressed: () {
              Navigator.push(
                context, // 當前的上下文
                MaterialPageRoute(
                  // 使用 MaterialPageRoute 來創建一個新的頁面
                  builder: (context) =>
                      IconSettings(), // 當新的頁面需要顯示時，構建 IconSettings()
                ),
              );
              print('Settings button clicked');
            },
          ),
        ],
      ),
    );
  }
}
