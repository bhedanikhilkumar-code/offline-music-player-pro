import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../providers/equalizer_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize equalizer with audio session ID after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initEqualizer();
    });
  }

  Future<void> _initEqualizer() async {
    final audioProvider = context.read<AudioProvider>();
    final eqProvider = context.read<EqualizerProvider>();
    final sessionId = audioProvider.androidAudioSessionId;
    if (sessionId > 0) {
      await eqProvider.initWithAudioSession(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: Consumer<EqualizerProvider>(
                builder: (context, eq, _) {
                  final primaryColor = themeProvider.primaryColor;
                  return Column(
                    children: [
                      // ─── App Bar ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Text(AppStrings.equalizer, style: AppTextStyles.headingMedium.copyWith(letterSpacing: 1.1)),
                            const Spacer(),
                            // ON/OFF toggle with premium look
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: eq.enabled
                                    ? LinearGradient(colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.1)])
                                    : null,
                                color: eq.enabled ? null : Colors.white10,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: eq.enabled ? primaryColor : Colors.white24,
                                  width: 1.5,
                                ),
                                boxShadow: eq.enabled
                                    ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    eq.enabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      color: eq.enabled ? primaryColor : Colors.white38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    height: 24,
                                    child: Switch(
                                      value: eq.enabled,
                                      onChanged: (v) => eq.setEnabled(v),
                                      activeColor: primaryColor,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─── Connection Status ───
                      if (!eq.isInitialized)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Play a song first to activate equalizer effects',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.amber, fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.amber, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: _initEqualizer,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ─── Preset Chips (scrollable) ───
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: AppConstants.eqPresets.keys.length,
                          itemBuilder: (context, index) {
                            final preset = AppConstants.eqPresets.keys.elementAt(index);
                            if (preset == 'Custom') return const SizedBox.shrink();
                            final isSelected = eq.preset == preset;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => eq.setPreset(preset),
                                  borderRadius: BorderRadius.circular(22),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.7)])
                                          : null,
                                      color: isSelected ? null : Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: isSelected
                                          ? [BoxShadow(color: primaryColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                                          : null,
                                      border: isSelected ? null : Border.all(color: Colors.white10),
                                    ),
                                    child: Text(
                                      preset,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white60,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ─── Current Preset indicator ───
                      if (eq.preset == 'Custom')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Custom EQ', style: AppTextStyles.bodySmall.copyWith(color: primaryColor, fontWeight: FontWeight.w600)),
                        ),

                      const SizedBox(height: 20),

                      // ─── EQ Bands with Glass Card ───
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              return _buildEqBand(context, eq, index, primaryColor);
                            }),
                          ),
                        ),
                      ),

                      // ─── Bass Boost & Virtualizer ───
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Column(
                          children: [
                            _buildEffectSlider(
                              context,
                              icon: Icons.speaker_rounded,
                              label: AppStrings.bassBoost,
                              value: eq.bassBoost,
                              onChanged: (v) => eq.setBassBoost(v),
                              enabled: eq.enabled,
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildEffectSlider(
                              context,
                              icon: Icons.surround_sound_rounded,
                              label: AppStrings.virtualizer,
                              value: eq.virtualizer,
                              onChanged: (v) => eq.setVirtualizer(v),
                              enabled: eq.enabled,
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEqBand(BuildContext context, EqualizerProvider eq, int index, Color primaryColor) {
    final level = eq.bandLevels[index];
    final isPositive = level >= 0;
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          // dB value label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: eq.enabled ? primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isPositive ? "+" : ""}${level.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: eq.enabled ? primaryColor : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Vertical slider
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 4),
                  activeTrackColor: eq.enabled ? primaryColor : Colors.white24,
                  inactiveTrackColor: Colors.white.withOpacity(0.08),
                  thumbColor: eq.enabled ? Colors.white : Colors.white38,
                  overlayColor: primaryColor.withOpacity(0.1),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: level,
                  min: -15, max: 15,
                  onChanged: eq.enabled ? (v) => eq.setBandLevel(index, v) : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Frequency label
          Text(
            AppConstants.eqBandLabels[index],
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: eq.enabled ? Colors.white60 : Colors.white30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectSlider(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required bool enabled,
    required Color primaryColor,
  }) {
    final percentage = (value / 10).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: enabled ? primaryColor : Colors.white24, size: 18),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(color: enabled ? Colors.white : Colors.white24)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: enabled ? primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: enabled ? primaryColor : Colors.white24,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: enabled ? primaryColor : Colors.white24,
              inactiveTrackColor: Colors.white.withOpacity(0.08),
              thumbColor: enabled ? Colors.white : Colors.white38,
              overlayColor: primaryColor.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1000,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
