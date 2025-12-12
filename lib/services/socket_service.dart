import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/socket_models.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  final _positionController = StreamController<SocketPosition>.broadcast();
  Timer? _reconnectTimer;
  String? _lastUrl;

  Stream<SocketPosition> get positionStream => _positionController.stream;
  bool get isConnected => _channel != null;

  /// Connect to the WebSocket server
  void connect(String url) {
    if (_channel != null) return;
    _lastUrl = url;

    try {
      print('🔌 Connecting to WebSocket: $url');
      
      // Ensure the URL is correctly parsed and uses wss scheme
      // The user provided 'wss://rastreobusmen.geovoy.com/api/socket'
      // We will force this specific URL to avoid any ambiguity from previous attempts
      final uri = Uri.parse(url);
      
      // Adding headers might help with 503 if it's a firewall/proxy issue
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'User-Agent': 'PostmanRuntime/7.29.0', // Mimic Postman or Browser
          'Origin': 'https://rastreobusmen.geovoy.com',
        },
      );

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket Error: $error');
          _scheduleReconnect(url);
        },
        onDone: () {
          print('⚠️ WebSocket Disconnected');
          _scheduleReconnect(url);
        },
      );
    } catch (e) {
      print('❌ Connection Exception: $e');
      _scheduleReconnect(url);
    }
  }

  void _scheduleReconnect(String url) {
    disconnect();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('🔄 Attempting to reconnect...');
      connect(url);
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message);
      
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
    _reconnectTimer?.cancel();
    _positionController.close();
  }
}
