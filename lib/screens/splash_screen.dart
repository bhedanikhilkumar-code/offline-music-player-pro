import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../services/permission_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'permission_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _mainController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _barsFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // Continuous wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Particle float
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Main reveal timeline (2.5s)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Logo: 0% → 35%
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    // Equalizer bars: 25% → 55%
    _barsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.25, 0.55, curve: Curves.easeOut)),
    );

    // Title: 45% → 70%
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.45, 0.7, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)),
    );

    // Subtitle: 60% → 85%
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 0.85, curve: Curves.easeOut)),
    );

    // Shimmer across text
    _shimmer = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.7, 1.0, curve: Curves.easeInOut)),
    );

    _mainController.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    try {
      final storage = await StorageService.getInstance();
      final hasPermission = await PermissionService.hasStoragePermission();

      if (!mounted) return;
      
      final Widget destination = (hasPermission && storage.permissionGranted)
          ? const HomeScreen()
          : const PermissionScreen();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Fallback: navigate to PermissionScreen on error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _waveController, _particleController]),
        builder: (context, _) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A1A),
                  Color(0xFF12102B),
                  Color(0xFF0E0C20),
                  Color(0xFF080818),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ─── Floating Particles ───
                ..._buildParticles(size),

                // ─── Ambient Glow behind logo ───
                Opacity(
                  opacity: _logoFade.value * 0.6,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF6B35).withOpacity(0.15),
                          const Color(0xFFFF6B35).withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // ─── Main Content ───
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Circle
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF8C00),
                                Color(0xFFFF6B35),
                                Color(0xFFE85D26),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.35),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.headphones_rounded,
                              size: 42,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Animated Equalizer Bars ───
                    Opacity(
                      opacity: _barsFade.value,
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (i) {
                            final phase = i * 0.9;
                            final wave = _waveController.value * 2 * math.pi + phase;
                            final height = 10 + 22 * ((math.sin(wave) + 1) / 2);
                            final barColor = Color.lerp(
                              const Color(0xFFFF8C00),
                              const Color(0xFFFF4081),
                              i / 6,
                            )!;
                            return Container(
                              width: 4,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: barColor.withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: barColor.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ─── App Name ───
                    SlideTransition(
                      position: _titleSlide,
                      child: Opacity(
                        opacity: _titleFade.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment(_shimmer.value - 1, 0),
                              end: Alignment(_shimmer.value, 0),
                              colors: const [
                                Colors.white,
                                Color(0xFFFFD740),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Player Pro',
                            style: AppTextStyles.headingLarge.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ─── Tagline ───
                    Opacity(
                      opacity: _subtitleFade.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20, height: 1,
                            color: const Color(0xFFFF8C00).withOpacity(0.4),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'OFFLINE MUSIC EXPERIENCE',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white30,
                              fontSize: 11,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 20, height: 1,
                            color: const Color(0xFFFF8C00).withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles(Size screenSize) {
    final random = math.Random(42);
    return List.generate(20, (i) {
      final startX = random.nextDouble() * screenSize.width;
      final startY = random.nextDouble() * screenSize.height;
      final particleSize = 2.0 + random.nextDouble() * 3;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final phase = random.nextDouble() * 2 * math.pi;

      final progress = (_particleController.value * speed + phase) % 1.0;
      final yOffset = -80 * progress;
      final xOscillation = math.sin(progress * 2 * math.pi) * 15;
      final opacity = (math.sin(progress * math.pi) * 0.4).clamp(0.0, 0.4);

      return Positioned(
        left: startX + xOscillation,
        top: startY + yOffset,
        child: Container(
          width: particleSize,
          height: particleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              const Color(0xFFFF8C00),
              const Color(0xFF7C4DFF),
              random.nextDouble(),
            )!.withOpacity(opacity),
          ),
        ),
      );
    });
  }
}
