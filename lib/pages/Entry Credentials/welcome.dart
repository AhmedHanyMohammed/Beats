import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'Login/login.dart';
import '../../components/styling.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextRoute = '/login',
    this.delay = const Duration(seconds: 3),
  });

  final String nextRoute;
  final Duration delay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      if (widget.nextRoute == '/login') {
        Navigator.of(context).pushReplacement(_buildLoginRoute()); // animated
      } else {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute); // fallback
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    for (final path in [
      'assets/images/Upper Left Beats.png',
      'assets/images/Lower Right Beats.png',
      'assets/images/White Logo.png',
    ]) {
      precacheImage(AssetImage(path), context).catchError((_) {});
    }
    _didPrecache = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    // Removed dynamic tl/br watermark sizes; use fixed dimensions instead.
    const double watermarkWidth = 196;
    const double watermarkHeight = 240;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _BackgroundGradient(),
          Positioned(
            top: 0,
            left: 0,
            child: _safeAsset(
              'assets/images/Upper Left Beats.png',
              width: watermarkWidth,
              height: watermarkHeight,
              opacity: 0.25,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _safeAsset(
              'assets/images/Lower Right Beats.png',
              width: watermarkWidth,
              height: watermarkHeight,
              opacity: 0.25,
            ),
          ),
          const Center(child: _Logo()),
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * 0.05,
            child: Text(
              'Beats ECG',
              textAlign: TextAlign.center,
              style: buttonTextStyle.copyWith(
                fontSize: shortest * 0.035,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF117FBC),
                Color(0xFF1289C8),
                Color(0xFFD25C5F),
                Color(0xFFF25345),
                Color(0xFFFE4030),
              ],
              stops: [0.0, 0.18, 0.42, 0.72, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.05),
              radius: 0.95,
              colors: [
                Color(0x29D25C5F),
                Color(0x00D25C5F),
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x1A000000),
                Colors.transparent,
                Color(0x2E000000),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  static const double targetWidth = 225.0;
  static const double targetHeight = 81.5;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = math.min(1.0, (size.width * 0.7) / targetWidth);
    return SizedBox(
      width: targetWidth * scale,
      height: targetHeight * scale,
      child: _safeAsset(
        'assets/images/White Logo.png',
        width: targetWidth * scale,
        height: targetHeight * scale,
        fit: BoxFit.contain,
      ),
    );
  }
}

Widget _safeAsset(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  double? opacity,
}) {
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    filterQuality: FilterQuality.high,
    opacity: opacity != null ? AlwaysStoppedAnimation(opacity) : null,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );
}

/// Builds the animated route to the LoginPage.
/// Animation: fade + upward slide + slight scale for clearer visibility.
PageRouteBuilder<void> _buildLoginRoute() {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (_, __, ___) =>  LoginPage(),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(curved);
      final scale = Tween<double>(begin: 0.97, end: 1.0).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );
    },
  );
}
