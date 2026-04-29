import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/equalizer_screen.dart';
import '../screens/sleep_timer_screen.dart';
import '../screens/theme_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.drawerGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Row(
                  children: [
                    Text(AppStrings.appName, style: AppTextStyles.drawerTitle),
                    const SizedBox(width: 12),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.accentOrange, AppColors.accentAmber],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.accentOrange.withOpacity(0.4), blurRadius: 12),
                        ],
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              // Menu items
              _menuItem(context, Icons.library_music_outlined, AppStrings.library, () {
                Navigator.pop(context);
              }),
              _menuItem(context, Icons.settings_outlined, AppStrings.settings, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
              const SizedBox(height: 8),
              _menuItem(context, Icons.equalizer_rounded, AppStrings.equalizer, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EqualizerScreen()));
              }),
              _menuItem(context, Icons.timer_outlined, AppStrings.sleepTimer, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTimerScreen()));
              }),
              _menuItem(context, Icons.color_lens_outlined, AppStrings.skinTheme, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen()));
              }),
              _menuItem(context, Icons.widgets_outlined, AppStrings.widgets, () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Widgets feature coming soon')),
                );
              }),
              const SizedBox(height: 8),
              _menuItem(context, Icons.block_rounded, AppStrings.removeAds, () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is an ad-free offline app!')),
                );
              }),
              _menuItem(context, Icons.volume_up_rounded, AppStrings.volumeBooster, () {
                Navigator.pop(context);
              }, badge: 'AD'),
              _menuItem(context, Icons.ring_volume_outlined, AppStrings.freeRingtones, () {
                Navigator.pop(context);
              }, badge: 'AD'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {String? badge}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 24),
      title: Row(
        children: [
          Text(label, style: AppTextStyles.drawerItem),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(badge, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
            ),
          ],
        ],
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}
