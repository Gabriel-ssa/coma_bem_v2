// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

const Color _darkGreen = Color(0xFF244C35);
const Color _background = Color(0xFFF9FAF5);
const Color _dotColor = Color(0xFFF7D2BB);


class _LeafData {
  final double x;
  final double y;
  final double size;
  final double rotation;
  const _LeafData(this.x, this.y, this.size, this.rotation);
}


class _DotData {
  final double x;
  final double y;
  final double size;
  const _DotData(this.x, this.y, this.size);
}

const List<_LeafData> _leaves = [
  _LeafData(0.50, 0.015, 34, 0.35),
  _LeafData(0.10, 0.115, 40, -0.45),
  _LeafData(0.82, 0.125, 42, 0.60),
  _LeafData(0.50, 0.245, 44, -0.35),
  _LeafData(0.17, 0.365, 40, 0.30),
  _LeafData(0.82, 0.375, 42, -0.55),
  _LeafData(0.17, 0.610, 40, 0.20),
  _LeafData(0.82, 0.620, 42, -0.35),
  _LeafData(0.50, 0.745, 44, 0.50),
  _LeafData(0.17, 0.865, 40, -0.25),
  _LeafData(0.82, 0.875, 42, 0.45),
  _LeafData(0.50, 0.985, 38, -0.40),
];

const List<_DotData> _dots = [
  _DotData(0.17, 0.057, 9),
  _DotData(0.27, 0.093, 8),
  _DotData(0.82, 0.057, 9),
  _DotData(0.07, 0.130, 9),
  _DotData(0.10, 0.142, 7),
  _DotData(0.18, 0.180, 9),
  _DotData(0.50, 0.170, 8),
  _DotData(0.53, 0.178, 7),
  _DotData(0.38, 0.230, 8),
  _DotData(0.82, 0.310, 8),
  _DotData(0.17, 0.310, 9),
  _DotData(0.50, 0.335, 8),
  _DotData(0.07, 0.395, 9),
  _DotData(0.10, 0.408, 7),
  _DotData(0.82, 0.400, 8),
  _DotData(0.17, 0.440, 8),
  _DotData(0.50, 0.660, 8),
  _DotData(0.82, 0.555, 8),
  _DotData(0.17, 0.545, 9),
  _DotData(0.38, 0.575, 8),
  _DotData(0.07, 0.625, 9),
  _DotData(0.10, 0.638, 7),
  _DotData(0.82, 0.705, 8),
  _DotData(0.38, 0.745, 8),
  _DotData(0.17, 0.785, 8),
  _DotData(0.82, 0.790, 8),
  _DotData(0.07, 0.840, 8),
  _DotData(0.10, 0.852, 7),
  _DotData(0.82, 0.945, 8),
  _DotData(0.17, 0.955, 8),
  _DotData(0.38, 0.965, 8),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.44;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          
          for (final d in _dots)
            Positioned(
              left: size.width * d.x - d.size / 2,
              top: size.height * d.y - d.size / 2,
              child: Container(
                width: d.size,
                height: d.size,
                decoration: const BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          
          for (final l in _leaves)
            Positioned(
              left: size.width * l.x - l.size / 2,
              top: size.height * l.y - (l.size * 1.25) / 2,
              child: Transform.rotate(
                angle: l.rotation,
                child: SizedBox(
                  width: l.size,
                  height: l.size * 1.25,
                  child: const CustomPaint(painter: _LeafPainter()),
                ),
              ),
            ),

          
          Center(child: ComaBemLogo(size: logoSize)),

          
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: _darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cyclone_rounded,
                        size: 18,
                        color: Color(0xFFCFE0D3),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFC3C0),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ComaBemLogo extends StatelessWidget {
  final double size;

  const ComaBemLogo({super.key, this.size = 135});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}


class _LeafPainter extends CustomPainter {
  const _LeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h)
      ..cubicTo(-w * 0.10, h * 0.75, w * 0.00, h * 0.20, w * 0.5, 0)
      ..cubicTo(w * 1.00, h * 0.20, w * 1.10, h * 0.75, w * 0.5, h)
      ..close();

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x66A8D5B5), Color(0x4D6FB08A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fill);

    
    final vein = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 1.02), Offset(w * 0.5, h * 0.18), vein);

    
    final side = Paint()
      ..color = const Color(0x44FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (final t in [0.35, 0.5, 0.65]) {
      final y = h * t;
      canvas.drawLine(Offset(w * 0.5, y), Offset(w * 0.22, y - h * 0.10), side);
      canvas.drawLine(Offset(w * 0.5, y), Offset(w * 0.78, y - h * 0.10), side);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}