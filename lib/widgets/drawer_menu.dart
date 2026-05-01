import 'dart:ui';
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
import '../screens/widgets_screen.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: themeProvider.backgroundDecoration,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Premium Header ───
                _buildHeader(primaryColor),

                const SizedBox(height: 8),

                // ─── Menu Items ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main section
                        _buildSectionLabel('MAIN'),
                        _buildAnimatedItem(0, Icons.library_music_rounded, AppStrings.library, primaryColor, () {
                          Navigator.pop(context);
                        }),
                        _buildAnimatedItem(1, Icons.settings_rounded, AppStrings.settings, Colors.white60, () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        }),

                        const SizedBox(height: 16),
                        _buildSectionLabel('TOOLS'),
                        _buildAnimatedItem(2, Icons.equalizer_rounded, AppStrings.equalizer, const Color(0xFF7C4DFF), () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EqualizerScreen()));
                        }),
                        _buildAnimatedItem(3, Icons.bedtime_rounded, AppStrings.sleepTimer, const Color(0xFF448AFF), () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTimerScreen()));
                        }),

                        const SizedBox(height: 16),
                        _buildSectionLabel('CUSTOMIZE'),
                        _buildAnimatedItem(4, Icons.palette_rounded, AppStrings.skinTheme, const Color(0xFFE91E63), () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen()));
                        }),
                        _buildAnimatedItem(5, Icons.widgets_rounded, AppStrings.widgets, const Color(0xFF00BCD4), () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetsScreen()));
                        }),

                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 8),

                        _buildAnimatedItem(6, Icons.workspace_premium_rounded, AppStrings.removeAds, const Color(0xFFFFD740), () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('This is an ad-free offline app!')),
                          );
                        }),
                        _buildAnimatedItem(7, Icons.volume_up_rounded, AppStrings.volumeBooster, Colors.white38, () {
                          Navigator.pop(context);
                        }, badge: 'AD'),
                        _buildAnimatedItem(8, Icons.ring_volume_rounded, AppStrings.freeRingtones, Colors.white38, () {
                          Navigator.pop(context);
                        }, badge: 'AD'),
                      ],
                    ),
                  ),
                ),

                // ─── Footer ───
                _buildFooter(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.12),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          // Animated Logo
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player Pro',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Premium Music Experience',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white24,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, IconData icon, String label, Color iconColor, VoidCallback onTap, {String? badge}) {
    final delay = index * 0.08;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          ((_animController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(-20 * (1 - progress), 0),
            child: child,
          ),
        );
      },
      child: _buildMenuItem(icon, label, iconColor, onTap, badge: badge),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color iconColor, VoidCallback onTap, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: iconColor.withOpacity(0.08),
          highlightColor: iconColor.withOpacity(0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Icon with subtle glow container
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: iconColor.withOpacity(0.1),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.drawerItem.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Text(
                      badge,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white30,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (badge == null)
                  Icon(Icons.chevron_right_rounded, color: Colors.white12, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.white10, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50),
              boxShadow: [
                BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.5), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'v2.0 • Offline',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.2),
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Icon(Icons.favorite_rounded, color: primaryColor.withOpacity(0.3), size: 14),
        ],
      ),
    );
  }
}
