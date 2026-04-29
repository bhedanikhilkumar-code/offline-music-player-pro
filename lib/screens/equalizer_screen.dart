import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../providers/equalizer_provider.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

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
          child: Consumer<EqualizerProvider>(
            builder: (context, eq, _) {
              return Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        Text(AppStrings.equalizer, style: AppTextStyles.headingMedium),
                        const Spacer(),
                        Switch(
                          value: eq.enabled,
                          onChanged: (v) => eq.setEnabled(v),
                        ),
                      ],
                    ),
                  ),
                  // Preset tabs
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: AppConstants.eqPresets.keys.map((preset) {
                        final isSelected = eq.preset == preset;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(preset),
                            selected: isSelected,
                            selectedColor: Theme.of(context).primaryColor,
                            backgroundColor: AppColors.cardDark,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            onSelected: (_) => eq.setPreset(preset),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // EQ bands
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return _buildEqBand(context, eq, index);
                        }),
                      ),
                    ),
                  ),
                  // Bass Boost & Virtualizer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildKnobRow(AppStrings.bassBoost, eq.bassBoost, (v) => eq.setBassBoost(v)),
                        const SizedBox(height: 16),
                        _buildKnobRow(AppStrings.virtualizer, eq.virtualizer, (v) => eq.setVirtualizer(v)),
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
  }

  Widget _buildEqBand(BuildContext context, EqualizerProvider eq, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${eq.bandLevels[index].toStringAsFixed(0)}dB', style: AppTextStyles.bodySmall),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.white12,
                thumbColor: Theme.of(context).primaryColor,
              ),
              child: Slider(
                value: eq.bandLevels[index],
                min: -10, max: 10,
                onChanged: eq.enabled ? (v) => eq.setBandLevel(index, v) : null,
              ),
            ),
          ),
        ),
        Text(AppConstants.eqBandLabels[index], style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildKnobRow(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: AppTextStyles.bodyMedium)),
        Expanded(
          child: Slider(
            value: value, min: 0, max: 1000,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text('${(value / 10).round()}%', style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
