import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final client = MqttServerClient('rd.ns.co.th', 'flutter_client');
  Function(String)? onMessageReceived; // Callback สำหรับส่ง payload ไปยัง UI
  Future<void> connectMQTT() async {
    client.logging(on: true);
    client.port = 1882; // Default MQTT port
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean();

    client.connectionMessage = connMessage;
    
    try {
      await client.connect();
    } catch (e) {
      print('Connection Exception: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus != null &&
        client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      const topic = 'test/topic';
      client.subscribe(topic, MqttQos.atMostOnce);
    } else {
      print('Failed to connect to MQTT broker');
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message: $payload from topic: ${c[0].topic}');
      if (onMessageReceived != null) {
        onMessageReceived!(payload);
      }
    });
    
  }

  void onConnected() {
    print('Connected');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }
}