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
  late VlcPlayerController
      _videoPlayerController; // ใช้ late เพื่อกำหนดค่าในภายหลัง

  @override
  void initState() {
    super.initState();
    _mqttService = MQTTService();
    _mqttService.onMessageReceived = _updatePayload; // กำหนด callback
    _mqttService.connectMQTT();

    initializePlayer();
  }

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController = VlcPlayerController.network(
        'http://192.168.10.126:8002/stream',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
      await _videoPlayerController.initialize();
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  // Callback สำหรับอัปเดต payload
  void _updatePayload(String payload) {
    setState(() {
      _payload = payload; // อัปเดต payload และ rebuild UI
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
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
            _videoPlayerController != null
                ? VlcPlayer(
                    controller: _videoPlayerController,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  )
                : CircularProgressIndicator(),
            // const Text(
            //   'Match',
            //    style: Theme.of(context).textTheme.headlineMedium,
            // ),
            // Text(
            // _payload,
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            Container( height: 10,),

            Container(
              padding:
                  const EdgeInsets.only(bottom: 0), // ระยะห่างจากข้อความข้างบน
              height: 100, // ความสูงของ Container
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5), // สีของเงา
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
