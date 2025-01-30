import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _payload = 'Waiting for data...'; // ตัวแปรเก็บ payl
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
        _payload = 'Waiting for data...'; // เปลี่ยนข้อความเมื่อหมดเวลา
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
      _payload = payload; // อัปเดต payload และ rebuild UI
      _shadowColor = _payload == '1'
          ? Colors.green.withOpacity(0.5) // สีเขียวหาก _payload == 1
          : _payload == '0'
              ? Colors.red.withOpacity(0.5) // สีแดงหาก _payload == 0
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _videoPlayerController != null
                        ? SizedBox(
                            width: 450,
                            height: 250,
                            child: VlcPlayer(
                              controller: _videoPlayerController,
                              aspectRatio: 16 / 9,
                              // _videoPlayerController
                              // .value.aspectRatio, //4/3, //16 / 9,
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
                              // _videoPlayerController
                              // .value.aspectRatio, //4/3, //16 / 9,
                              placeholder:
                                  Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : CircularProgressIndicator(),
                  ]),
                ]),
            // const Text(
            //   'Match',
            //    style: Theme.of(context).textTheme.headlineMedium,
            // ),
            // Text(
            // _payload,
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            SizedBox(
              height: 10,
            ),

            Container(
              padding:
                  const EdgeInsets.only(bottom: 0), // ระยะห่างจากข้อความข้างบน
              height: 100, // ความสูงของ Container
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor,
                    // color: _payload == '1'
                    //     ? Colors.green
                    //         .withOpacity(0.5) // สีเขียวหาก _payload == 1
                    //     : _payload == '0'
                    //         ? Colors.red.withOpacity(0.5)
                    //         : Colors.blue
                    //             .withOpacity(0.5), // สีแดงหาก _payload != 1
                    spreadRadius: 2, // การกระจายของเงา
                    blurRadius: 2, // ความเบลอของเงา
                    // offset: Offset(0, 3), // ตำแหน่งของเงา (แกน X, แกน Y)
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.center, // จัดข้อความไว้กลาง Container
                child: Text(
                  _payload, // เพิ่มข้อความที่ต้องการแสดง
                  style: TextStyle(
                    fontSize: 24, // ขนาดตัวอักษร
                    fontWeight: FontWeight.bold, // ตัวหนา (หากต้องการ)
                    color: Colors.black, // สีของข้อความ
                  ),
                  textAlign:
                      TextAlign.center, // จัดข้อความให้อยู่กึ่งกลางแนวนอน
                  maxLines: 2, // จำนวนบรรทัดสูงสุด
                  overflow:
                      TextOverflow.ellipsis, // หากข้อความยาวเกินให้แสดง ...
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
