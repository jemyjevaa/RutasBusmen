import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _initParticles();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500), // Longer for smoother feel
      vsync: this,
    )..forward();
    
    // Navigate to main app after animation completes
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.child,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }
  
  void _initParticles() {
    final random = Random();
    // Create 20 particles for a fuller animation
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: -0.1 - (random.nextDouble() * 0.3), // Start above screen
        size: 20 + random.nextDouble() * 40,
        speed: 0.3 + random.nextDouble() * 0.4,
        color: i % 2 == 0 
          ? const Color(0xFFFF6302) // Orange
          : const Color(0xFF1D61E7), // Blue
        delay: i * 0.08,
      ));
    }
    
    // Last particle is the hero - always orange, falls to center then expands
    _particles.add(Particle(
      x: 0.5, // Center X
      y: -0.2,
      size: 50,
      speed: 0.6, // Falls a bit faster to reach center
      color: const Color(0xFFFF6302),
      delay: 0.5, // Starts after some particles are already falling
      isHero: true,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              progress: _controller.value,
              screenSize: MediaQuery.of(context).size,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final double delay;
  final bool isHero;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.delay,
    this.isHero = false,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Size screenSize;
  
  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.screenSize,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calculate particle progress with delay
      final particleProgress = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      
      if (particleProgress <= 0) continue;
      
      // Hero particle has special behavior: fall then expand
      if (particle.isHero) {
        // Phase 1 (0-60%): Fall to center
        // Phase 2 (60-100%): Expand from center
        if (progress < 0.6) {
          // Still falling
          _drawFallingParticle(canvas, size, particle, particleProgress);
        } else {
          // Start expansion
          _drawHeroExpansion(canvas, size, particle, progress);
        }
      } else {
        // Regular particles just fall
        _drawFallingParticle(canvas, size, particle, particleProgress);
      }
    }
  }
  
  void _drawHeroExpansion(Canvas canvas, Size size, Particle particle, double progress) {
    // Expansion starts at 60% and goes to 100%
    final expansionProgress = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
    // Ultra smooth expansion curve
    final easedExpansion = Curves.easeInOutQuart.transform(expansionProgress);
    
    // Start from particle size and expand to cover screen
    final maxSize = sqrt(size.width * size.width + size.height * size.height) * 1.3;
    final currentSize = particle.size + (maxSize * easedExpansion);
    
    // Always centered
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw expanding circle with SOLID vibrant orange
    final paint = Paint()
      ..color = particle.color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      currentSize / 2,
      paint,
    );
  }
  
  void _drawFallingParticle(Canvas canvas, Size size, Particle particle, double particleProgress) {
    // Smooth falling with easing
    final easedProgress = Curves.easeInQuad.transform(particleProgress);
    
    // Calculate position
    final x = particle.x * size.width + sin(particleProgress * pi * 2) * 30;
    final y = particle.y * size.height + easedProgress * size.height * 1.3;
    
    // Fade in and out
    final opacity = (sin(particleProgress * pi) * 1.2).clamp(0.0, 1.0);
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = particle.color.withOpacity(opacity * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(
      Offset(x + 2, y + 4),
      particle.size / 2,
      shadowPaint,
    );
    
    // Draw particle with gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          particle.color.withOpacity(opacity),
          particle.color.withOpacity(opacity * 0.6),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y),
        radius: particle.size / 2,
      ));
    
    canvas.drawCircle(
      Offset(x, y),
      particle.size / 2,
      paint,
    );
    
    // Add highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.4);
    
    canvas.drawCircle(
      Offset(x - particle.size * 0.15, y - particle.size * 0.15),
      particle.size * 0.2,
      highlightPaint,
    );
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
