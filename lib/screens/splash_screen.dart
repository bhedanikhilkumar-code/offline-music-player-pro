import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final storage = await StorageService.getInstance();
    final hasPermission = await PermissionService.hasStoragePermission();

    if (!mounted) return;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            hasPermission && storage.permissionGranted ? const HomeScreen() : const PermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.accentOrange, AppColors.accentAmber],
                          ),
                          boxShadow: [
                            BoxShadow(color: AppColors.accentOrange.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.music_note_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text('Music Player', style: AppTextStyles.headingLarge),
                      const SizedBox(height: 8),
                      Text('Offline Audio Player', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

