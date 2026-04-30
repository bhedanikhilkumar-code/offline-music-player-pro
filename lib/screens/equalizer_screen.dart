import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../providers/equalizer_provider.dart';
import '../providers/audio_provider.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  final Color _amberColor = const Color(0xFFFFA500); // Standard amber/orange from screenshot
  
  bool _is10Bands = false;
  String _selectedReverb = 'Medium Hall';
  final List<String> _reverbOptions = [
    'None',
    'Small Room',
    'Medium Room',
    'Large Room',
    'Medium Hall',
    'Large Hall',
    'Plate'
  ];
  
  // Local state for 10 bands
  final List<String> _10BandLabels = ['31Hz', '62Hz', '125Hz', '250Hz', '500Hz', '1kHz', '2kHz', '4kHz', '8kHz', '16kHz'];
  final List<double> _10BandValues = List.filled(10, 0.0);

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep dark background
      body: SafeArea(
        child: Consumer<EqualizerProvider>(
          builder: (context, eq, _) {
            final isEnabled = eq.enabled;
            final primaryColor = isEnabled ? _amberColor : Colors.white24;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── App Bar ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text('Equalizer', style: AppTextStyles.headingMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Simple Amber Switch
                      Switch(
                        value: eq.enabled,
                        onChanged: (v) => eq.setEnabled(v),
                        activeColor: Colors.white,
                        activeTrackColor: _amberColor,
                        inactiveThumbColor: Colors.white54,
                        inactiveTrackColor: Colors.white12,
                      ),
                    ],
                  ),
                ),

                // ─── Connection Status ───
                if (!eq.isInitialized)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Text(
                      'Play a song to activate effects',
                      style: AppTextStyles.bodySmall.copyWith(color: _amberColor, fontSize: 12),
                    ),
                  ),

                // ─── Preset Chips (2 Rows Horizontal Scroll) ───
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (AppConstants.eqPresets.keys.length / 2).ceil(),
                    itemBuilder: (context, columnIndex) {
                      final keys = AppConstants.eqPresets.keys.toList();
                      final index1 = columnIndex * 2;
                      final index2 = index1 + 1;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            if (index1 < keys.length) _buildPresetChip(keys[index1], eq),
                            const SizedBox(height: 10),
                            if (index2 < keys.length) _buildPresetChip(keys[index2], eq),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ─── EQ Bands ───
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _is10Bands
                                ? List.generate(10, (index) => _build10EqBand(context, index, primaryColor, isEnabled))
                                : List.generate(5, (index) => _build5EqBand(context, eq, index, primaryColor)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 5 Bands / 10 Bands Toggle
                        Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _is10Bands = false),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: !_is10Bands && isEnabled ? _amberColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Text('5 Bands', style: TextStyle(color: !_is10Bands && isEnabled ? Colors.black : Colors.white70, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _is10Bands = true),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _is10Bands && isEnabled ? _amberColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Text('10 Bands', style: TextStyle(color: _is10Bands && isEnabled ? Colors.black : Colors.white70, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Reverb Dropdown ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reverb', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      PopupMenuButton<String>(
                        initialValue: _selectedReverb,
                        color: const Color(0xFF262626),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (String item) {
                          setState(() {
                            _selectedReverb = item;
                          });
                          // Map string to index (0-6)
                          final index = _reverbOptions.indexOf(item);
                          if (index != -1) {
                            eq.setReverb(index);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return _reverbOptions.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(
                                choice,
                                style: TextStyle(
                                  color: _selectedReverb == choice ? Colors.white : Colors.white60,
                                  fontWeight: _selectedReverb == choice ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        child: Row(
                          children: [
                            Text(_selectedReverb, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Bass Boost & Virtualizer ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildDashedSliderRow(
                        label: 'Bass Boost',
                        value: eq.bassBoost,
                        onChanged: (v) => eq.setBassBoost(v),
                        enabled: eq.enabled,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildDashedSliderRow(
                        label: 'Virtualizer',
                        value: eq.virtualizer,
                        onChanged: (v) => eq.setVirtualizer(v),
                        enabled: eq.enabled,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPresetChip(String preset, EqualizerProvider eq) {
    final isSelected = eq.preset == preset;
    final isEnabled = eq.enabled;
    return GestureDetector(
      onTap: isEnabled ? () => eq.setPreset(preset) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected && isEnabled && !_is10Bands ? _amberColor : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          preset,
          style: TextStyle(
            color: isSelected && isEnabled && !_is10Bands ? Colors.black : Colors.white70,
            fontWeight: isSelected && !_is10Bands ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _build5EqBand(BuildContext context, EqualizerProvider eq, int index, Color primaryColor) {
    final level = eq.bandLevels[index];
    final isPositive = level >= 0;
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Text(
            '${isPositive ? "+" : ""}${(level / 10).toStringAsFixed(1)}',
            style: TextStyle(
              color: isPositive && eq.enabled ? primaryColor : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 0),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: primaryColor,
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.eqBandLabels[index],
            style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _build10EqBand(BuildContext context, int index, Color primaryColor, bool isEnabled) {
    final level = _10BandValues[index];
    final isPositive = level >= 0;
    return SizedBox(
      width: 25, // Thinner for 10 bands
      child: Column(
        children: [
          Text(
            '${isPositive ? "+" : ""}${(level / 10).toStringAsFixed(1)}',
            style: TextStyle(
              color: isPositive && isEnabled ? primaryColor : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7, elevation: 0),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.1),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: level,
                      min: -15, max: 15,
                      onChanged: isEnabled ? (v) => setState(() => _10BandValues[index] = v) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _10BandLabels[index],
            style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedSliderRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required bool enabled,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white54 : Colors.white24,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: _DashedSlider(
            value: value / 1000, // 0.0 to 1.0
            onChanged: enabled ? (v) => onChanged(v * 1000) : null,
            activeColor: primaryColor,
            inactiveColor: Colors.white12,
          ),
        ),
      ],
    );
  }
}

class _DashedSlider extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const _DashedSlider({
    required this.value,
    this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (onChanged == null) return;
        final box = context.findRenderObject() as RenderBox;
        final dx = details.localPosition.dx;
        var newValue = dx / box.size.width;
        onChanged!(newValue.clamp(0.0, 1.0));
      },
      onTapDown: (details) {
        if (onChanged == null) return;
        final box = context.findRenderObject() as RenderBox;
        final dx = details.localPosition.dx;
        var newValue = dx / box.size.width;
        onChanged!(newValue.clamp(0.0, 1.0));
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final dashCount = 30;
        final activeCount = (dashCount * value).round();
        return Container(
          height: 30,
          color: Colors.transparent, // expand tap area
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(dashCount, (index) {
              bool isActive = index < activeCount;
              bool isThumb = index == activeCount || (index == dashCount - 1 && value == 1.0 && activeCount == dashCount);
              
              return Container(
                width: 4,
                height: isThumb ? 20 : 12,
                decoration: BoxDecoration(
                  color: isActive || isThumb ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
