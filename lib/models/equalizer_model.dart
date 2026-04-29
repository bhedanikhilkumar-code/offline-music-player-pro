class EqualizerModel {
  final String presetName;
  final List<double> bandLevels; // 5 bands
  final double bassBoost; // 0 to 1000
  final double virtualizer; // 0 to 1000
  final bool enabled;

  EqualizerModel({
    required this.presetName,
    required this.bandLevels,
    this.bassBoost = 0,
    this.virtualizer = 0,
    this.enabled = false,
  });

  EqualizerModel copyWith({
    String? presetName,
    List<double>? bandLevels,
    double? bassBoost,
    double? virtualizer,
    bool? enabled,
  }) {
    return EqualizerModel(
      presetName: presetName ?? this.presetName,
      bandLevels: bandLevels ?? List.from(this.bandLevels),
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      enabled: enabled ?? this.enabled,
    );
  }

  static EqualizerModel get defaultEq => EqualizerModel(
        presetName: 'Normal',
        bandLevels: [0, 0, 0, 0, 0],
        bassBoost: 0,
        virtualizer: 0,
        enabled: false,
      );
}
