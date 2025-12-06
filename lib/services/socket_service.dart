import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/socket_models.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  final _positionController = StreamController<SocketPosition>.broadcast();

  Stream<SocketPosition> get positionStream => _positionController.stream;
  bool get isConnected => _channel != null;

  /// Connect to the WebSocket server
  void connect(String url) {
    if (_channel != null) return;

    try {
      print('🔌 Connecting to WebSocket: $url');
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket Error: $error');
          disconnect();
        },
        onDone: () {
          print('❌ WebSocket Disconnected');
          disconnect();
        },
      );
    } catch (e) {
      print('❌ Connection Exception: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message);
      // Assuming the message is a single position object
      // If it's a list, we would iterate. 
      // Based on requirements: "Server sends stream of data JSON"
      // Usually it's one object per event or a list.
      // I'll assume it handles both or single object.
      
      if (decoded is Map<String, dynamic>) {
        final position = SocketPosition.fromJson(decoded);
        _positionController.add(position);
      } else if (decoded is List) {
        for (var item in decoded) {
          if (item is Map<String, dynamic>) {
            final position = SocketPosition.fromJson(item);
            _positionController.add(position);
          }
        }
      }
    } catch (e) {
      print('⚠️ Error parsing socket message: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  void dispose() {
    disconnect();
    _positionController.close();
  }
}
