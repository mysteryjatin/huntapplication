import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hunt_property/services/storage_service.dart';

class SpinPopupScreen extends StatefulWidget {
  const SpinPopupScreen({super.key});

  @override
  State<SpinPopupScreen> createState() => _SpinPopupScreenState();
}

class _SpinPopupScreenState extends State<SpinPopupScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _celebrationController;
  late AnimationController _bounceController;
  late Animation<double> _animation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _bounceAnimation;

  double _rotationAngle = 0;
  bool _isSpinning = false;
  bool _showCelebration = false;
  List<Offset> _confettiParticles = [];
  List<Offset> _balloons = [];
  List<Offset> _spinParticles = [];

  final List<String> _segments = [
    'Platinum\nUnlimited\nAccess',
    'Better Luck\nNext Time',
    'Metal',
    'Bronze',
    'Silver',
    'Gold',
  ];

  final List<Color> _colors = [
    const Color(0xFFFFA000),
    const Color(0xFFFFECB3),
    const Color(0xFFFFCC80),
    const Color(0xFFFFB74D),
    const Color(0xFFFFE082),
    const Color(0xFFFFF59D),
  ];

  @override
  void initState() {
    super.initState();
    // Start with wheel at a random position
    _rotationAngle = 0;

    // Main spin animation with bounce effect at the end
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Celebration animation
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    );

    // Bounce animation when wheel stops
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    _initializeCelebration();
    _initializeSpinParticles();
  }

  void _initializeSpinParticles() {
    final random = math.Random();
    _spinParticles = List.generate(30, (_) => Offset(
      random.nextDouble() * 300 - 150,
      random.nextDouble() * 300 - 150,
    ));
  }

  void _initializeCelebration() {
    final random = math.Random();
    // Create confetti particles
    _confettiParticles = List.generate(50, (_) => Offset(
      random.nextDouble() * 400 - 200,
      -50 - random.nextDouble() * 100,
    ));

    // Create balloons
    _balloons = List.generate(8, (_) => Offset(
      random.nextDouble() * 400 - 200,
      400 + random.nextDouble() * 100,
    ));
  }

  void _spinWheel() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _showCelebration = false;
    });

    final segmentAngle = 2 * math.pi / _segments.length;
    const targetIndex = 0; // Always land on Platinum Unlimited Access
    final random = math.Random();

    // More energetic spin: 6-8 full rotations
    final extraSpins = 6 + random.nextInt(3);

    // Calculate target rotation to align segment 0 center with arrow
    // Arrow is fixed at top center (pointing down at -90 degrees)
    // In WheelPainter: segment 0 starts at -90 degrees (top)
    // Segment 0 center is at: -90 + (segmentAngle/2) degrees
    // To align segment 0 center with arrow at -90 degrees:
    // We need to rotate by -segmentAngle/2 (counter-clockwise)
    // Since rotation is additive, target = -segmentAngle/2 normalized to 0-2π

    final currentRotation = _rotationAngle % (2 * math.pi);
    final targetRotation = (2 * math.pi - segmentAngle / 2) % (2 * math.pi);

    // Calculate rotation needed from current position
    var rotationNeeded = targetRotation - currentRotation;
    if (rotationNeeded < 0) {
      rotationNeeded += 2 * math.pi;
    }

    // Add extra spins and the rotation needed to land on target
    _rotationAngle += (extraSpins * 2 * math.pi) + rotationNeeded;

    // Start spin animation
    _controller.forward(from: 0).then((_) {
      // Bounce effect when wheel stops
      _bounceController.forward(from: 0).then((_) {
        _bounceController.reverse();
      });

      setState(() {
        _isSpinning = false;
        _showCelebration = true;
      });

      // Start celebration
      _celebrationController.forward(from: 0).then((_) async {
        // Mark spin popup as shown
        await StorageService.setSpinPopupShown(true);
        // Close bottom sheet and navigate to result screen
        if (mounted) {
          Navigator.of(context).pop(); // Close bottom sheet
          Navigator.of(context).pushNamed('/spin-result');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ===== HEADER =====
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 22, 20, 14),
                child: Column(
                  children: [
                    Text(
                      'Spin to Unlock Your Reward',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Exclusive reward for new users',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== WHEEL =====
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fixed Arrow at top center (outside rotation)
                    Positioned(
                      top: -6,
                      child: _buildFixedArrow(),
                    ),
                    // Spinning Wheel with bounce effect
                    AnimatedBuilder(
                      animation: Listenable.merge([_animation, _bounceAnimation]),
                      builder: (_, __) {
                        return Transform.scale(
                          scale: _bounceAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAngle * _animation.value,
                            child: _buildWheel(_rotationAngle * _animation.value),
                          ),
                        );
                      },
                    ),
                    // Spin particles effect
                    if (_isSpinning)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, _) {
                          return _buildSpinParticles();
                        },
                      ),
                    // Celebration overlay
                    if (_showCelebration)
                      AnimatedBuilder(
                        animation: _celebrationAnimation,
                        builder: (context, _) {
                          return _buildCelebration();
                        },
                      ),
                  ],
                ),
              ),

              // ===== BUTTON =====
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _spinWheel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSpinning
                            ? Colors.grey[400]
                            : const Color(0xFF2FED9A),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: _isSpinning ? 0 : 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSpinning) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            _isSpinning ? 'Spinning...' : ' Spin Now',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Terms & Conditions apply',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  // ===== FIXED ARROW =====
  Widget _buildFixedArrow() {
    return Container(
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Arrow shadow for depth
          Positioned(
            top: 2,
            child: CustomPaint(
              size: const Size(24, 14),
              painter: PointerPainter(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          // Main black arrow - fixed at top center
          CustomPaint(
            size: const Size(34, 18),
            painter: PointerPainter(color: Colors.black),
          ),
          // Arrow glow effect when spinning
          if (_isSpinning)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Opacity(
                  opacity: 0.6 + (0.4 * math.sin(_animation.value * 12)),
                  child: CustomPaint(
                    size: const Size(28, 16),
                    painter: PointerPainter(color: const Color(0xFFFFA000)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ===== WHEEL UI =====
  Widget _buildWheel(double currentAngle) {
    const double wheelSize = 300;

    return SizedBox(
      width: wheelSize,
      height: wheelSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glow effect when spinning
          if (_isSpinning)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Container(
                  width: wheelSize + 20,
                  height: wheelSize + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: const Color(0xFFFFA000).withOpacity(
                    //       0.3 + (0.2 * math.sin(_animation.value * 8)),
                    //     ),
                    //     blurRadius: 30,
                    //     spreadRadius: 5,
                    //   ),
                    // ],
                  ),
                );
              },
            ),
          // White border + shadow
          Container(
            width: wheelSize,
            height: wheelSize,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.18),
              //     blurRadius: 22,
              //     offset: const Offset(0, 10),
              //   ),
              // ],
            ),
            child: CustomPaint(
              painter: WheelPainter(_segments, _colors),
            ),
          ),

          // ===== CENTER CIRCLE (keeps orientation upright) =====
          buildCenterCircle(currentAngle),
        ],
      ),
    );
  }

  // ===== SPIN PARTICLES EFFECT =====
  Widget _buildSpinParticles() {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(340, 340),
        painter: SpinParticlesPainter(
          particles: _spinParticles,
          animationValue: _animation.value,
        ),
      ),
    );
  }

  // ===== CELEBRATION ANIMATION =====
  Widget _buildCelebration() {
    final random = math.Random();
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(340, 340),
        painter: CelebrationPainter(
          confettiParticles: _confettiParticles,
          balloons: _balloons,
          animationValue: _celebrationAnimation.value,
        ),
      ),
    );
  }

  // ===== CENTER CIRCLE =====
  Widget buildCenterCircle(double currentAngle) {
    return Transform.rotate(
      angle: -currentAngle, // keep text/logo upright while wheel spins
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer shadow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),

          // Inner content
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.center, // keep logo + text perfectly centered
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 46, //
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/images/WhatsApp Image 2025-10-31 at 17.29.24_0d656493.jpg',
                    ),
                  ),
                ),

                const SizedBox(height: 2),
                const Text(
                  'Spin\nNow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

// ===== WHEEL PAINTER =====
class WheelPainter extends CustomPainter {
  final List<String> segments;
  final List<Color> colors;

  WheelPainter(this.segments, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final angle = 2 * math.pi / segments.length;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < segments.length; i++) {
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * angle - math.pi / 2,
        angle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final textAngle = i * angle + angle / 2 - math.pi / 2;
      final offset = Offset(
        center.dx + math.cos(textAngle) * radius * 0.7,
        center.dy + math.sin(textAngle) * radius * 0.7,
      );

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ===== INVERTED TRIANGLE ARROW =====
class PointerPainter extends CustomPainter {
  final Color color;

  PointerPainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Add border for better visibility
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => oldDelegate.color != color;
}

// ===== SPIN PARTICLES PAINTER =====
class SpinParticlesPainter extends CustomPainter {
  final List<Offset> particles;
  final double animationValue;

  SpinParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random();

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final angle = (animationValue * 2 * math.pi * 8) + (i * 0.5);
      final distance = 120 + (i % 3) * 20;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final opacity = (1.0 - (animationValue * 0.5)).clamp(0.3, 1.0);
      final paint = Paint()
        ..color = const Color(0xFFFFA000).withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4 + (i % 3) * 2, paint);
    }
  }

  @override
  bool shouldRepaint(SpinParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// ===== CELEBRATION PAINTER =====
class CelebrationPainter extends CustomPainter {
  final List<Offset> confettiParticles;
  final List<Offset> balloons;
  final double animationValue;

  CelebrationPainter({
    required this.confettiParticles,
    required this.balloons,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw confetti
    final confettiColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    for (var i = 0; i < confettiParticles.length; i++) {
      final particle = confettiParticles[i];
      final color = confettiColors[i % confettiColors.length];
      final progress = (animationValue * 2).clamp(0.0, 1.0);

      final x = center.dx + particle.dx;
      final y = center.dy + particle.dy + (progress * 500);
      final rotation = progress * 2 * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 8, height: 8),
        paint,
      );
      canvas.restore();
    }

    // Draw balloons
    for (var i = 0; i < balloons.length; i++) {
      final balloon = balloons[i];
      final color = confettiColors[i % confettiColors.length];
      final progress = (animationValue * 1.5).clamp(0.0, 1.0);

      final x = center.dx + balloon.dx;
      final y = center.dy + balloon.dy - (progress * 400);

      if (y > 0) {
        final paint = Paint()
          ..color = color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

        // Draw balloon
        canvas.drawCircle(Offset(x, y), 20, paint);

        // Draw balloon string
        final stringPaint = Paint()
          ..color = Colors.grey.withOpacity(0.6)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(x, y + 20),
          Offset(x, y + 60),
          stringPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
