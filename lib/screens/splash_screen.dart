import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'permission_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Future<void>? restFuture;
  const SplashScreen({super.key, this.restFuture});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    try {
      // Small delay just to ensure the flutter engine has rendered the first frame
      // so the animation plays smoothly.
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      final storage = await StorageService.getInstance();
      final hasPermission = await PermissionService.hasStoragePermission();

      if (!mounted) return;

      Widget destination;
      if (hasPermission) {
        // Save permission state for future launches
        // NOTE: Notification permission is deferred to first playback to avoid
        // Activity lifecycle disruption that causes auto-back crash on Android 13+.
        if (!storage.permissionGranted) {
          await storage.setPermissionGranted(true);
        }
        destination = const HomeScreen();
      } else {
        destination = const PermissionScreen();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the theme's background color while doing the instant transition
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
