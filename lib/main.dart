import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'app_bar.dart'; // Import ไฟล์ CustomAppBar
import 'page/detect.dart'; // อย่าลืม import ไฟล์ใหม่ที่สร้าง
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:convert'; // ใช้สำหรับการแปลง JSON เป็น Map
import 'mqtt_service.dart'; // นำเข้าไฟล์ mqtt_service.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SIPH MED AI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MQTTService _mqttService;
  String _payload = 'N/A'; // ตัวแปรเก็บ payl
  String? _class = '0';
  String? _score = '0';
  Color _shadowColor = Colors.blue.withOpacity(0.5);
  late VlcPlayerController
      _videoPlayerController; // ใช้ late เพื่อกำหนดค่าในภายหลัง
  late VlcPlayerController _videoPlayerController2; // กล้องตัวที่สอง

  @override
  void initState() {
    super.initState();
    _mqttService = MQTTService();
    _mqttService.onMessageReceived = _updatePayload; // กำหนด callback
    _mqttService.connectMQTT();

    initializePlayer();
    initializePlayer2();

    // _startTimer(); // เริ่มนับเวลา 5 วินาที
  }

  //  @override
  // void initState() {
  //   super.initState();
  //   _startTimer(); // เริ่มนับเวลา 5 วินาที
  // }

  // void _startTimer() {
  //   Future.delayed(Duration(seconds: 5), () {
  //     setState(() {
  //       _payload = 'Waiting for data...';
  //       _shadowColor  = Colors.blue.withOpacity(0.5); // เปลี่ยนสีหลังจาก 5 วินาที
  //     });
  //   });
  // }
  void _startTimer() {
    // เริ่มทำงานเมื่อ 5 วินาทีผ่านไป
    Future.delayed(const Duration(seconds: 5), () {
      // if (_payload == 'Waiting for data...') {
      setState(() {
        _payload = 'N/A'; // เปลี่ยนข้อความเมื่อหมดเวลา
        _class = '0';
        _score = '0';
        _shadowColor =
            Colors.blue.withOpacity(0.5); // เปลี่ยนสีของเงาหลังจาก 5 วินาที
      });
      // }
    });
  }

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController = VlcPlayerController.network(
        'http://192.168.10.126:8001/stream',
        hwAcc: HwAcc.disabled,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
      await _videoPlayerController.initialize();
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  Future<void> initializePlayer2() async {
    try {
      _videoPlayerController2 = VlcPlayerController.network(
        'http://192.168.10.126:8002/stream',
        hwAcc: HwAcc.disabled,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
      await _videoPlayerController2.initialize();
    } catch (e) {
      print("Error initializing video player2: $e");
    }
  }

  // // Callback สำหรับอัปเดต payload
  // void _updatePayload(String payload) {
  //   setState(() {
  //     _payload = payload; // อัปเดต payload และ rebuild UI
  //   });
  // }
  void _updatePayload(String payload) {
    setState(() {
      _startTimer();
      // แปลง payload เป็น JSON และดึงค่า match
      Map<String, dynamic> jsonData =
          jsonDecode(payload); // แปลง payload เป็น Map
      String? match = jsonData['match']; // ดึงค่าจาก key "match"
      print('Match value: $match'); // แสดงค่าของ match
      // ดึงค่าจาก key "obj" และ key "class" ภายใน obj
      String? objClass =
          jsonData['obj'] != null ? jsonData['obj']['class'].toString() : null;
      print('Class value: $objClass'); // แสดงค่าของ class จาก obj
      _class = objClass;
      double? objScore =
          jsonData['obj'] != null ? jsonData['obj']['score'] : 0.0;
      // print('Score value: $objScore'); // แสดงค่าของ class จาก obj
      _score = ((objScore ?? 0.0) * 100).toStringAsFixed(2);
      print(_score);
      // _payload = payload; // อัปเดต payload และ rebuild UI
      _payload = match == 'Y'
          ? "MATCHED"
          : match == 'N'
              ? "UNMATCHED" // สีแดงหาก match == 0
              : "N/A"; // สีฟ้าหาก match อื่นๆ
      _shadowColor = match == 'Y'
          ? Colors.green.withOpacity(0.5) // สีเขียวหาก match == 1
          : match == 'N'
              ? Colors.red.withOpacity(0.5) // สีแดงหาก payload == 0
              : Colors.blue.withOpacity(0.5); // สีฟ้าหาก payload อื่นๆ
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
    await _videoPlayerController2.stopRendererScanning();
    await _videoPlayerController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        // แทนที่ navigationBar ด้วย child ที่มี Column
        child: Column(
          children: [
            Container(
              height: 100, // ปรับความสูงตามต้องการ
              color: CupertinoColors.systemBackground,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/2.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'SIPH MED AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton.tinted(
                      minSize: 50,
                      // padding: EdgeInsets.all(10),
                      onPressed: () {},
                      child: Text('DETECT'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const SecondPage()),
                        );
                      },
                      child: Text('HISTORY'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const ThirdPage()),
                        );
                      },
                      child: Text('SETUP'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: HomeWidget(
                  payload: _payload,
                  className: _class,
                  score: _score,
                  shadowColor: _shadowColor,
                  videoPlayerController: _videoPlayerController,
                  videoPlayerController2: _videoPlayerController2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        // แทนที่ navigationBar ด้วย child ที่มี Column
        child: Column(
          children: [
            Container(
              height: 100, // ปรับความสูงตามต้องการ
              color: CupertinoColors.systemBackground,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/2.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'SIPH MED AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      minSize: 50,
                      // padding: EdgeInsets.all(10),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  const MyHomePage(title: 'SIPH MED AI')),
                        );
                      },
                      child: Text('DETECT'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton.tinted(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {},
                      child: Text('HISTORY'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const ThirdPage()),
                        );
                      },
                      child: Text('SETUP'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('HISTORY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        // แทนที่ navigationBar ด้วย child ที่มี Column
        child: Column(
          children: [
            Container(
              height: 100, // ปรับความสูงตามต้องการ
              color: CupertinoColors.systemBackground,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/2.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'SIPH MED AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      minSize: 50,
                      // padding: EdgeInsets.all(10),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  const MyHomePage(title: 'SIPH MED AI')),
                        );
                      },
                      child: Text('DETECT'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const SecondPage()),
                        );
                      },
                      child: Text('HISTORY'),
                    ),
                    SizedBox(width: 20),
                    CupertinoButton.tinted(
                      // padding: EdgeInsets.all(10),
                      minSize: 50,
                      onPressed: () {},
                      child: Text('SETUP'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('SETUP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
