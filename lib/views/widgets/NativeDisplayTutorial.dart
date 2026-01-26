import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/eta_native_service.dart';
import '../../viewmodels/route_viewmodel.dart';

class NativeDisplayTutorial extends StatefulWidget {
  final VoidCallback onComplete;

  const NativeDisplayTutorial({Key? key, required this.onComplete}) : super(key: key);

  @override
  _NativeDisplayTutorialState createState() => _NativeDisplayTutorialState();
}

class _NativeDisplayTutorialState extends State<NativeDisplayTutorial> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var imagePath in _androidImages) {
      precacheImage(AssetImage(imagePath), context);
    }
    for (var imagePath in _iosImages) {
      precacheImage(AssetImage(imagePath), context);
    }
    precacheImage(const AssetImage('assets/images/tutorials/Tuto5.png'), context);
    precacheImage(const AssetImage('assets/images/tutorials/TutoIOS3.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFFF6B35);

    return Scaffold(
      backgroundColor: Colors.transparent, // Crucial for overlay effect
      body: Stack(
        children: [
          // Blur Background
          GestureDetector(
            onTap: widget.onComplete, // Dismiss on background tap
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Indicator (Floating)
                if (!_showFinalSlide)
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 4,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? primaryOrange : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),

                // PageContent (Floating Flyer Cards)
                Expanded(
                  child: _showFinalSlide 
                    ? _buildFlyerPage(
                        imagePath: _finalImage,
                        title: 'Okay, en otro momento',
                        description: 'Si deseas activar la nueva funcionalidad, en el menú lateral tendrás la opción de hacerlo o desactivarlo en cualquier momento.',
                        isFinal: true,
                      )
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return _buildFlyerPage(
                            imagePath: _images[index],
                            title: _titles[index],
                            description: _descriptions[index],
                            isActionPage: index == _images.length - 1,
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyerPage({
    required String imagePath,
    required String title,
    required String description,
    bool isActionPage = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              
              // Text Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Buttons logic
                    if (isFinal)
                      _buildButton('ENTENDIDO', onPressed: widget.onComplete, isPrimary: true)
                    else if (isActionPage)
                      Column(
                        children: [
                          _buildButton('ACTIVAR AHORA', onPressed: () async {
                            final viewModel = context.read<RouteViewModel>();
                            if (Platform.isAndroid) {
                              viewModel.setActivatingFeature(true);
                              await _etaNativeService.requestOverlayPermission();
                            } else {
                              // iOS specific: Now request says to turn it ON if they click Activate
                              viewModel.toggleShowETAOutsideApp(true);
                            }
                            widget.onComplete();
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
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutQuart,
                              );
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
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: FittedBox(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: FittedBox(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
