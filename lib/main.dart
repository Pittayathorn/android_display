import 'package:flutter/material.dart';
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
  String? _score  = '0';
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
        _score='0';
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
      Map<String, dynamic> jsonData = jsonDecode(payload); // แปลง payload เป็น Map
      String? match = jsonData['match']; // ดึงค่าจาก key "match"
      print('Match value: $match'); // แสดงค่าของ match
        // ดึงค่าจาก key "obj" และ key "class" ภายใน obj
      String? objClass = jsonData['obj'] != null ? jsonData['obj']['class'].toString() : null;
      print('Class value: $objClass'); // แสดงค่าของ class จาก obj
      _class = objClass;
      double ? objScore = jsonData['obj'] != null ? jsonData['obj']['score']:  0.0;
      // print('Score value: $objScore'); // แสดงค่าของ class จาก obj
      _score =  ((objScore ?? 0.0) * 100).toStringAsFixed(2); 
      print(_score); 
      // _payload = payload; // อัปเดต payload และ rebuild UI
      _payload = match == 'Y'
          ? "MATCHED"
          : match == 'N'
              ? "UNMATCHED" // สีแดงหาก match == 0
              : "N/A"; // สีฟ้าหาก match อื่นๆ
      _shadowColor=match == 'Y'
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Expanded(
            child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // จัดปุ่มไปทางซ้ายสุด
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/2.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
                    width: 50, // ปรับขนาดตามต้องการ
                    height: 50,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("SIPH MED AI"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('DETECT'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SecondPage()),
                      );
                    },
                    child: const Text('HISTORY'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ThirdPage()),
                      );
                    },
                    child: const Text('SETUP'),
                  ),
                ]),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Image.asset(
            //   'assets/images/1.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
            //   width: 200, // ปรับขนาดตามต้องการ
            //   height: 200,
            // ),
            // Image.network(
            //   'https://devimages-cdn.apple.com/wwdc-services/articles/images/3D5F5DD3-14F7-4384-94C0-798D15EE7CD7/2048.jpeg',
            //   width: 200,
            //   height: 200,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // ขึ้นต้นจากซ้าย
              children: [
                // คอลัมน์ที่มีตัวเล่นวิดีโอ
                Column(
                  children: [
                    _videoPlayerController != null
                        ? SizedBox(
                            width: 450,
                            height: 250,
                            child: VlcPlayer(
                              controller: _videoPlayerController,
                              aspectRatio: 16 / 9,
                              placeholder:
                                  Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : CircularProgressIndicator(),
                    _videoPlayerController2 != null
                        ? SizedBox(
                            width: 450,
                            height: 250,
                            child: VlcPlayer(
                              controller: _videoPlayerController2,
                              aspectRatio: 16 / 9,
                              placeholder:
                                  Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : CircularProgressIndicator(),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                // คอลัมน์ที่มีข้อความ
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // ขึ้นต้นจากซ้าย
                    children: [
                      // Text "Match" ที่อยู่บนสุด
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // กระจาย widget ให้ห่างเท่า ๆ กัน
                        children: [
                          Text('RESULT# 0'),
                          Text('MED# 0'),
                          Text('LABEL# 0'),
                          Text('CLASS# ${_class }'),
                          Text('SCORE# ${_score}'),
                          Text('FEEDBACK# 0'),
                          Text('USER FEEDBACK# 0'),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, // ชิดซ้าย
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // ขึ้นต้นจากซ้าย
                        children: [
                          // Container ที่แสดง payload ยืดเต็มความกว้าง
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // ขึ้นต้นจากซ้าย
                              children: [
                                // กล่องข้อความเดิมที่มีอยู่
                                Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 0), // ระยะห่างจากข้อความข้างบน
                                  height: 100, // ความสูงของ Container
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: _shadowColor,
                                        spreadRadius: 2, // การกระจายของเงา
                                        blurRadius: 2, // ความเบลอของเงา
                                      ),
                                    ],
                                  ),
                                  child: Align(
                                    alignment: Alignment
                                        .center, // จัดข้อความไว้กลาง Container
                                    child: Text(
                                      _payload, // เพิ่มข้อความที่ต้องการแสดง
                                      style: TextStyle(
                                        fontSize: 24, // ขนาดตัวอักษร
                                        fontWeight: FontWeight.bold, // ตัวหนา
                                        color: Colors.black, // สีของข้อความ
                                      ),
                                      textAlign: TextAlign
                                          .center, // จัดข้อความให้อยู่กึ่งกลาง
                                      maxLines: 2, // จำนวนบรรทัดสูงสุด
                                      overflow: TextOverflow
                                          .ellipsis, // หากข้อความยาวเกินให้แสดง ...
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        20), // ระยะห่างระหว่างกล่องข้อความ 2 กล่อง
                                // กล่องข้อความใหม่ที่เพิ่มขึ้น
                                Container(
                                  padding: const EdgeInsets.all(
                                      16), // กำหนดระยะห่างภายใน Container
                                  height: 200, // ความสูงของ Container
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 255, 255,
                                        255), // สีพื้นหลังของกล่องใหม่
                                    borderRadius:
                                        BorderRadius.circular(15), // มุมโค้ง
                                    boxShadow: [
                                      BoxShadow(
                                        // color: _shadowColor,
                                        // spreadRadius: 2,
                                        // blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // จัดให้อยู่ตรงกลางในแนวตั้ง
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly, // กระจาย widget ในแนวนอน
                                        children: [
                                          // Icon(Icons.star,
                                          //     color: Colors.blue,
                                          //     size: 30), // เพิ่มไอคอน
                                          SizedBox(width: 20),
                                          Image.asset(
                                            'assets/images/2.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
                                            width: 50, // ปรับขนาดตามต้องการ
                                            height: 100,
                                          ),
                                          SizedBox(width: 30),
                                          Expanded(
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start, // จัดให้อยู่ตรงกลางในแนวตั้ง
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start, // ขึ้นต้นจากซ้าย
                                                children: [
                                                  Text(
                                                    'ข้อความที่ 1',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'ข้อความที่ 2',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        10), // กำหนดระยะห่างภายในกรอบ
                                                    decoration: BoxDecoration(
                                                      color: const Color
                                                          .fromARGB(
                                                          255,
                                                          255,
                                                          255,
                                                          255), // สีพื้นหลังของกรอบ
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8), // มุมโค้ง
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 33, 243, 96),
                                                          width:
                                                              2), // กรอบสีเขียว
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .centerLeft, // จัดข้อความให้อยู่ซ้าย
                                                      child: Text(
                                                        'ข้อความที่ 3',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                          SizedBox(width: 30),
                                          Image.asset(
                                            'assets/images/3.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
                                            width: 100, // ปรับขนาดตามต้องการ
                                            height: 100,
                                          ),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              10), // ช่องว่างระหว่าง Row และข้อความ
                                      // Text(
                                      //   'ข้อความใหม่',
                                      //   style: TextStyle(
                                      //     fontSize: 24, // ขนาดตัวอักษร
                                      //     fontWeight: FontWeight.bold, // ตัวหนา
                                      //     color: Colors.black, // สีของข้อความ
                                      //   ),
                                      //   textAlign: TextAlign
                                      //       .center, // จัดข้อความให้อยู่กึ่งกลาง
                                      //   maxLines: 2, // จำนวนบรรทัดสูงสุด
                                      //   overflow: TextOverflow
                                      //       .ellipsis, // หากข้อความยาวเกินให้แสดง ...
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // คอลัมน์ที่มีข้อความ "Match" ทางขวา
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end, // ชิดขวา
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                    50), // กำหนดระยะห่างภายในวงกลม
                                decoration: BoxDecoration(
                                  color: Colors.blue, // สีพื้นหลังของวงกลม
                                  shape: BoxShape
                                      .circle, // ทำให้ container เป็นวงกลม
                                ),
                                child: Text(
                                  'ถูกต้อง', // ข้อความที่ต้องการแสดง
                                  style: TextStyle(
                                    color: Colors.white, // สีของข้อความ
                                    fontSize: 24, // ขนาดของข้อความ
                                    fontWeight: FontWeight
                                        .bold, // ขนาดตัวหนา (หากต้องการ)
                                  ),
                                ),
                              ),
                              SizedBox(height: 20), // ระยะห่างระหว่างวงกลม
                              Container(
                                padding: EdgeInsets.all(
                                    50), // กำหนดระยะห่างภายในวงกลม
                                decoration: BoxDecoration(
                                  color: Colors.blue, // สีพื้นหลังของวงกลม
                                  shape: BoxShape
                                      .circle, // ทำให้ container เป็นวงกลม
                                ),
                                child: Text(
                                  'ไม่ถูกต้อง', // ข้อความที่ต้องการแสดง
                                  style: TextStyle(
                                    color: Colors.white, // สีของข้อความ
                                    fontSize: 20, // ขนาดของข้อความ
                                    fontWeight: FontWeight
                                        .bold, // ขนาดตัวหนา (หากต้องการ)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),

            SizedBox(
              height: 10,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าใหม่'),
        actions: [
          Expanded(
            child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // จัดปุ่มไปทางซ้ายสุด
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/2.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
                    width: 50, // ปรับขนาดตามต้องการ
                    height: 50,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('SIPH MED AI'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: 'Your Title Here')),
                      );
                    },
                    child: const Text('DETECT'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('HISTORY'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ThirdPage()),
                      );
                    },
                    child: const Text('SETUP'),
                  ),
                ]),
          ),
        ],
      ),
      body: const Center(
        child: Text('นี่คือลิ้งค์ไปยังหน้าใหม่'),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าใหม่'),
        actions: [
          Expanded(
            child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // จัดปุ่มไปทางซ้ายสุด
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/2.png', // แทนที่ด้วยชื่อไฟล์รูปของคุณ
                    width: 50, // ปรับขนาดตามต้องการ
                    height: 50,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('SIPH MED AI'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: 'Your Title Here')),
                      );
                    },
                    child: const Text('DETECT'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SecondPage()),
                      );
                    },
                    child: const Text('HISTORY'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('SETUP'),
                  ),
                ]),
          ),
        ],
      ),
      body: const Center(
        child: Text('This is the third page'),
      ),
    );
  }
}
