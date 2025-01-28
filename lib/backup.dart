import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// import 'mqtt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  int _counter = 0;
  late MqttClient client;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  Future<void> _connectMQTT() async {
    client = MqttClient('broker.hivemq.com', 'flutter_client');
    client.port = 1883; // Default MQTT port
    client.logging(on: true); // Enable logging to see connection info

    try {
      await client.connect();
      print('MQTT Client connected');
    } catch (e) {
      print('MQTT connection failed: $e');
    }

    // Subscribe to a topic (optional)
    client.subscribe('test/topic', MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final MqttPublishMessage message = c![0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message: $payload');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            Image.network(
              'https://devimages-cdn.apple.com/wwdc-services/articles/images/3D5F5DD3-14F7-4384-94C0-798D15EE7CD7/2048.jpeg',
              width: 200,
              height: 200,
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: {_incrementCounter, _publishMessage()},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _publishMessage() async {
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello MQTT');
    client.publishMessage('test/topic', MqttQos.atMostOnce, builder.payload!);
    print('Message sent');
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
