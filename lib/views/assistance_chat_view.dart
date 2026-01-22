import 'package:flutter/material.dart';
import 'package:geovoy_app/models/login_response.dart';
import 'package:geovoy_app/services/ResponseServ.dart';
import 'package:geovoy_app/services/UserSession.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/app_strings.dart';

class AssistanceChatView extends StatefulWidget {
  const AssistanceChatView({super.key});

  @override
  State<AssistanceChatView> createState() => _AssistanceChatViewState();
}

class _AssistanceChatViewState extends State<AssistanceChatView> {
  static const Color primaryOrange = Color(0xFFFF6B35);
  final ScrollController _scrollController = ScrollController();

  final UserSession session = UserSession();
  
  // Lista de mensajes en el chat
  final List<ChatMessage> _messages = [];
  
  // Opciones actuales disponibles para el usuario
  List<ChatOption> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    // Mensaje inicial del bot
    _addBotMessage('¡Hola! Soy tu asistente virtual. ¿En qué puedo ayudarte hoy?');
    _showInitialOptions();
  }

  void _showInitialOptions() {
    setState(() {
      _currentOptions = [
        ChatOption(id: 'routes', text: 'Dudas sobre Rutas'),
        ChatOption(id: 'app_issue', text: 'Problemas con la App'),
        ChatOption(id: 'contact', text: 'Contactar Soporte'),
      ];
    });
  }

  void _handleOption(ChatOption option) {
    
    _addUserMessage(option.text);
    
    
    setState(() {
      _currentOptions = [];
    });

    
    Future.delayed(const Duration(milliseconds: 600), () {

      Empresa? company = session.getCompanyData();

      switch (option.id) {
        case 'routes':
          _addBotMessage('Para ver las rutas, ve a la pantalla principal "Mapa".\n\nPuedes seleccionar:\n• Frecuentes: Tus rutas habituales\n• En Tiempo: Rutas activas ahora\n• Todas: Lista completa');
          _showReturnOptions();
          break;
          _showReturnOptions();
          break;
        case 'app_issue':
          _addBotMessage('Si la app falla, intenta:\n1. Cerrar y abrir la app\n2. Verificar tu conexión a internet\n3. Asegurarte de tener la última versión');
          _showReturnOptions();
          break;
        case 'contact':
          _addBotMessage('Entiendo que necesitas ayuda personalizada. Puedes contactar a nuestra línea de asistencia directa.');
          _showContactOptions();
          break;
        case 'call_now':

          if(company!.telefonos.trim().isEmpty){
            _addBotMessage('No hay número de teléfono disponible.');
            _showReturnOptions();
            return;
          }
          _addBotMessage('Llamando al siguiente número:\n\n📞 ${company?.telefonos}');
          _showReturnOptions();
          makePhoneCall( company!.telefonos.toString() );
          break;
        case 'back':
          _addBotMessage('¿Hay algo más en lo que pueda ayudarte?');
          _showInitialOptions();
          break;
      }
    });
  }

  void _showReturnOptions() {
    setState(() {
      _currentOptions = [
        ChatOption(id: 'contact', text: 'No resolvió mi duda'),
        ChatOption(id: 'back', text: 'Volver al inicio'),
      ];
    });
  }

  void _showContactOptions() {
    setState(() {
      _currentOptions = [
        ChatOption(id: 'call_now', text: 'Llamar al número de asistencia'),
        ChatOption(id: 'back', text: 'Volver al inicio'),
      ];
    });
  }

  void _addBotMessage(String text) {

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        backgroundColor: primaryOrange,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_currentOptions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _currentOptions.map((option) {
                  return ActionChip(
                    label: Text(option.text),
                    onPressed: () => _handleOption(option),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: primaryOrange.withOpacity(0.5)),
                    ),
                    labelStyle: const TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? primaryOrange : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }



  Future<void> makePhoneCall(String phoneNumber) async {
    // Limpia espacios o caracteres no numéricos innecesarios (opcional)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final Uri uri = Uri.parse('tel:$cleanNumber');

    try {
      // Omitir canLaunchUrlString puede ayudar si falla la verificación
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // fuerza abrir app externa
      );
    } catch (e) {
      print(e);
      debugPrint('Error al lanzar llamada: $e');
      // Manejo adicional si quieres — mostrar alerta, etc.
    }
  }


}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatOption {
  final String id;
  final String text;

  ChatOption({required this.id, required this.text});
}
