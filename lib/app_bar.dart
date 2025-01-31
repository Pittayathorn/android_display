// custom_app_bar.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'main.dart' //หน้า MyHomePage ของคุณ
// import 'page/detect.dart'; // Import หน้า MyHomePage ของคุณ
// import 'page/history.dart'; // Import หน้า ThirdPage ของคุณ
// import 'page/setting.dart'; // Import หน้า ThirdPage ของคุณ


class AppBarCupertinoNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text('Home'),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/2.png',
            width: 50,
            height: 50,
          ),
          SizedBox(width: 20),
          Text('SIPH MED AI'),
          SizedBox(width: 20),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Text('DETECT'),
          ),
          SizedBox(width: 20),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const SecondPage()),
              );
            },
            child: Text('HISTORY'),
          ),
          SizedBox(width: 20),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const ThirdPage()),
              );
            },
            child: Text('SETUP'),
          ),
        ],
      ),
    );
  }
}