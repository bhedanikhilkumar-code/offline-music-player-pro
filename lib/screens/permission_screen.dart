import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../services/permission_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import '../providers/music_library_provider.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requesting = false;

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    final granted = await PermissionService.requestStoragePermission();
    await PermissionService.requestNotificationPermission();

    if (granted) {
      final storage = await StorageService.getInstance();
      await storage.setPermissionGranted(true);
      await storage.setFirstLaunch(false);
      if (!mounted) return;
      await context.read<MusicLibraryProvider>().init(storage);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _requesting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied. Tap to open settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => PermissionService.openSettings(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardDark,
                    border: Border.all(color: AppColors.accentOrange.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.folder_open_rounded, size: 56, color: AppColors.accentOrange),
                ),
                const SizedBox(height: 32),
                Text(AppStrings.permissionRequired, style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(
                  AppStrings.storagePermissionMsg,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _requesting ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _requesting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(AppStrings.grantPermission, style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
