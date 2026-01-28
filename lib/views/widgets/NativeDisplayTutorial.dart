import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/eta_native_service.dart';
import '../../viewmodels/route_viewmodel.dart';

class NativeDisplayTutorial extends StatefulWidget {
  final VoidCallback onComplete;

  const NativeDisplayTutorial({Key? key, required this.onComplete}) : super(key: key);

  @override
  _NativeDisplayTutorialState createState() => _NativeDisplayTutorialState();
}

class _NativeDisplayTutorialState extends State<NativeDisplayTutorial> {
  @override
  void initState() {
    super.initState();
    // Mark tutorial as shown immediately when opened to avoid spaming in some race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteViewModel>().setTutorialShown(true);
    });
  }

  int _currentIndex = 0;
  bool _showFinalSlide = false;
  final ETANativeService _etaNativeService = ETANativeService();

  // Android Lists
  final List<String> _androidImages = [
    'assets/images/tutorials/Tuto1.png',
    'assets/images/tutorials/Tuto2.png',
    'assets/images/tutorials/Tuto3.png',
    'assets/images/tutorials/Tuto4.png',
  ];

  // iOS Lists
  final List<String> _iosImages = [
    'assets/images/tutorials/TutoIOS1.png',
    'assets/images/tutorials/TutoIOS2.png',
    'assets/images/tutorials/TutoIOS4.png',
  ];

  final List<String> _androidTitles = [
    '¡Seguimos innovando!',
    'Te enseñamos a activarlo',
    '¡Ya casi!',
    'Y ¡Listo!',
  ];

  final List<String> _iosTitles = [
    '¡Seguimos innovando!',
    'Te enseñamos a activarlo',
    'Y ¡Listo!',
  ];

  final List<String> _androidDescriptions = [
    'Usamos actividad en segundo plano para que el tiempo de tu unidad siga visible aunque salgas de la app.',
    'Si decides activarlo ahora, te llevaremos a Ajustes > Actividad en segundo plano. Ahí busca BUSMEN MX.',
    'Lo único que necesitas hacer es habilitarlo.',
    'Ya podrás disfrutar de la nueva función de BUSMEN MX, pensada para ti.',
  ];

  final List<String> _iosDescriptions = [
    'Usamos Live Activities para que el tiempo de tu unidad siga visible en tu pantalla de bloqueo.',
    'Si decides activarlo ahora, recibirás actualizaciones en tiempo real sobre tu unidad.',
    'Ya podrás disfrutar de la nueva función de BUSMEN MX, pensada para ti.',
  ];

  List<String> get _images => Platform.isIOS ? _iosImages : _androidImages;
  List<String> get _titles => Platform.isIOS ? _iosTitles : _androidTitles;
  List<String> get _descriptions => Platform.isIOS ? _iosDescriptions : _androidDescriptions;
  String get _finalImage => Platform.isIOS ? 'assets/images/tutorials/TutoIOS3.png' : 'assets/images/tutorials/Tuto5.png';

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFFF6B35);

    return Stack(
      children: [
        // Semi-transparent background
        GestureDetector(
          onTap: widget.onComplete,
          child: Container(
            color: Colors.black.withOpacity(0.85),
          ),
        ),
        
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Indicator (Dots)
                    if (!_showFinalSlide)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_images.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 4,
                              width: _currentIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index ? primaryOrange : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),
                    
                    // The Flyer Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Image Section
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(24),
                                child: Image.asset(
                                  _showFinalSlide ? _finalImage : _images[_currentIndex],
                                  fit: BoxFit.contain,
                                  cacheWidth: 800,
                                ),
                              ),
                            ),
                          ),
                          
                          // Text Content Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            child: Column(
                              children: [
                                Text(
                                  _showFinalSlide ? 'Okay, en otro momento' : _titles[_currentIndex],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _showFinalSlide 
                                    ? 'Si deseas activar la nueva funcionalidad, en el menú lateral tendrás la opción de hacerlo o desactivarlo en cualquier momento.'
                                    : _descriptions[_currentIndex],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                
                                // Buttons logic
                                if (_showFinalSlide)
                                  _buildButton('ENTENDIDO', onPressed: widget.onComplete, isPrimary: true)
                                else if (_currentIndex == _images.length - 1)
                                  Column(
                                    children: [
                                      _buildButton('ACTIVAR AHORA', onPressed: () async {
                                        final viewModel = context.read<RouteViewModel>();
                                        
                                        // 1. Mark explicit intent to enable feature (Essential for auto-activation)
                                        await viewModel.markWantsNativeETA(true);
                                        
                                        // 2. Request notification permission
                                        await Permission.notification.request();
                                        
                                        // 3. Close tutorial overlay
                                        widget.onComplete();
                                        
                                        // 4. Trigger system settings (Android only)
                                        if (Platform.isAndroid) {
                                          await Future.delayed(const Duration(milliseconds: 150));
                                          await _etaNativeService.requestOverlayPermission();
                                        }
                                        
                                        // 5. Final sync to turn on both the toggle and the native display
                                        await viewModel.syncBackgroundActivityState();
                                      }, isPrimary: true),
                                      const SizedBox(height: 12),
                                      _buildButton('AHORA NO', onPressed: () {
                                        setState(() => _showFinalSlide = true);
                                      }, isPrimary: false),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildButton('OMITIR', onPressed: widget.onComplete, isPrimary: false),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildButton('SIGUIENTE', onPressed: () {
                                          setState(() {
                                            _currentIndex++;
                                          });
                                        }, isPrimary: true),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close icon outside for extra convenience
                    const SizedBox(height: 24),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: widget.onComplete,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
    );
  }
}
