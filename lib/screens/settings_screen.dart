import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../providers/music_library_provider.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'hidden_music_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(AppStrings.settings, style: AppTextStyles.headingMedium),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: [
                        // ─── General Section ───
                        _sectionHeader('General', const Color(0xFF00BFFF)),
                        
                        _settingsTile(
                          context,
                          icon: Icons.workspace_premium_rounded,
                          iconColor: const Color(0xFFFFD700),
                          title: AppStrings.goPremium,
                          subtitle: null,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Premium features available in offline mode!')),
                            );
                          },
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.radar_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.scanMusic,
                          subtitle: null,
                          onTap: () async {
                            final library = context.read<MusicLibraryProvider>();
                            await library.scanMusic();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Found ${library.totalSongs} songs')),
                              );
                            }
                          },
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.visibility_off_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.hiddenMusic,
                          subtitle: 'View and manage hidden music',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HiddenMusicScreen()));
                          },
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.cloud_upload_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.backupRestore,
                          subtitle: 'Last backup: ${settings.lastBackupDate}',
                          onTap: () async {
                            await settings.updateBackupDate();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Backup simulated and date updated!')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        
                        // ─── Playback Settings ───
                        _switchSettingsTile(
                          context,
                          icon: Icons.swap_calls_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.crossfade,
                          subtitle: 'Previous song fades out, next song fades in',
                          value: settings.crossfadeEnabled,
                          onChanged: (v) => settings.setCrossfade(v),
                        ),
                        _switchSettingsTile(
                          context,
                          icon: Icons.graphic_eq_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.gaplessPlayback,
                          subtitle: 'Play seamlessly between songs. Some devices may experience playback issues',
                          value: settings.gaplessEnabled,
                          onChanged: (v) => settings.setGapless(v),
                        ),
                        _switchSettingsTile(
                          context,
                          icon: Icons.brightness_high_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.keepScreenOn,
                          subtitle: 'Stay on while on the player screen',
                          value: settings.keepScreenOn,
                          onChanged: (v) => settings.setKeepScreenOn(v),
                        ),
                        _switchSettingsTile(
                          context,
                          icon: Icons.lock_outline_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.lockScreenPlaying,
                          subtitle: 'Show now playing when lock screen',
                          value: settings.lockScreenPlaying,
                          onChanged: (v) => settings.setLockScreenPlaying(v),
                        ),
                        _switchSettingsTile(
                          context,
                          icon: Icons.headset_off_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.pauseOnDetach,
                          subtitle: 'Toggle for pausing playback when headphone is detached',
                          value: settings.pauseOnHeadphoneDetach,
                          onChanged: (v) => settings.setPauseOnDetach(v),
                          activeColor: AppColors.accentOrange,
                        ),
                        const SizedBox(height: 4),

                        _switchSettingsTile(
                          context,
                          icon: Icons.notifications_active_outlined,
                          iconColor: const Color(0xFF448AFF),
                          title: AppStrings.notifications,
                          subtitle: 'Stay informed with the latest content',
                          value: settings.notificationEnabled,
                          onChanged: (v) => settings.setNotification(v),
                          activeColor: AppColors.accentOrange,
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.language_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.language,
                          subtitle: 'System default',
                          onTap: () => _showLanguageDialog(context, settings),
                        ),

                        const SizedBox(height: 8),
                        
                        // ─── Privacy Section ───
                        _sectionHeader('Privacy & Security', Colors.greenAccent),
                        _switchSettingsTile(
                          context,
                          icon: Icons.lock_rounded,
                          iconColor: Colors.greenAccent,
                          title: 'Privacy Lock',
                          subtitle: 'Lock hidden music with a PIN',
                          value: settings.privacyLockEnabled,
                          onChanged: (v) {
                            if (v) {
                              _showSetPinDialog(context, settings);
                            } else {
                              settings.setPrivacyLock(false);
                            }
                          },
                        ),
                        if (settings.privacyLockEnabled)
                          _settingsTile(
                            context,
                            icon: Icons.pin_rounded,
                            iconColor: Colors.white70,
                            title: 'Change PIN',
                            subtitle: 'Update your privacy PIN',
                            onTap: () => _showSetPinDialog(context, settings),
                          ),

                        const SizedBox(height: 8),

                        // ─── Help Section ───
                        _sectionHeader('Help', AppColors.accentOrange),

                        _settingsTile(
                          context,
                          icon: Icons.help_outline_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.faq,
                          subtitle: 'Help you better use the app',
                          onTap: () {},
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.feedback_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.feedback,
                          subtitle: 'Report bugs and tell us what to improve',
                          onTap: () {},
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.star_border_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.rateUs,
                          subtitle: 'Like this app? Please rate us!',
                          onTap: () {},
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.verified_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.manageSubscription,
                          subtitle: null,
                          onTap: () {},
                          trailingWidget: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.shield_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.privacyPolicy,
                          subtitle: null,
                          onTap: () {},
                        ),
                        _settingsTile(
                          context,
                          icon: Icons.description_outlined,
                          iconColor: Colors.white70,
                          title: AppStrings.termsOfUse,
                          subtitle: null,
                          onTap: () {},
                        ),

                        const SizedBox(height: 4),

                        _settingsTile(
                          context,
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.white70,
                          title: AppStrings.version,
                          subtitle: AppConstants.appVersion,
                          onTap: () {},
                          showChevron: false,
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.sectionHeader.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showChevron = true,
    Widget? trailingWidget,
  }) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: AppTextStyles.settingsTitle),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.settingsSubtitle, maxLines: 2)
          : null,
      trailing: trailingWidget ?? (showChevron ? const Icon(Icons.chevron_right, color: Colors.white24, size: 20) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _switchSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: AppTextStyles.settingsTitle),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.settingsSubtitle, maxLines: 2)
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? Theme.of(context).primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  void _showSetPinDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Set Privacy PIN', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                settings.setPrivacyPin(controller.text);
                settings.setPrivacyLock(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy PIN set!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a 4-digit PIN')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final languages = ['System default', 'English', 'Hindi', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.language, style: AppTextStyles.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang, style: AppTextStyles.bodyMedium),
              value: lang,
              groupValue: settings.selectedLanguage,
              activeColor: AppColors.accentOrange,
              onChanged: (v) {
                if (v != null) settings.setLanguage(v);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
