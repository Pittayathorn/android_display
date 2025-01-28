import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;  // Add this flag

  @override
  void initState() {
    super.initState();
    _mqttService = MQTTService();
    _mqttService.onMessageReceived = _updatePayload; // กำหนด callback
    _mqttService.connectMQTT();

   initializeVideoPlayer();
  }
  Future<void> initializeVideoPlayer() async {
    try {
     final _videoPlayerController = VideoPlayerController.network(
        'http://192.168.10.126:8002/stream',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);  // Optional: if you want the video to loop
      }
    } catch (e) {
      print('Error initializing video player: $e');
      // Handle error appropriately
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
    // Callback สำหรับอัปเดต payload
  void _updatePayload(String payload) {
    setState(() {
      _payload = payload; // อัปเดต payload และ rebuild UI
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose(); // ปล่อยทรัพยากรเมื่อ widget ถูกทำลาย
    super.dispose();
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
             _isVideoInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _payload,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

