class EqualizerService {
  // Visual-only equalizer for MVP
  // Real audio processing would require platform channels to Android's AudioEffect API
  // This stores and exposes EQ values that the UI can display

  static final EqualizerService _instance = EqualizerService._();
  factory EqualizerService() => _instance;
  EqualizerService._();

  bool _enabled = false;
  String _preset = 'Normal';
  List<double> _bandLevels = [0, 0, 0, 0, 0];
  double _bassBoost = 0;
  double _virtualizer = 0;

  bool get enabled => _enabled;
  String get preset => _preset;
  List<double> get bandLevels => List.from(_bandLevels);
  double get bassBoost => _bassBoost;
  double get virtualizer => _virtualizer;

  void setEnabled(bool value) => _enabled = value;
  void setPreset(String name) => _preset = name;
  void setBandLevels(List<double> levels) => _bandLevels = List.from(levels);
  void setBandLevel(int index, double level) {
    if (index >= 0 && index < _bandLevels.length) {
      _bandLevels[index] = level;
    }
  }
  void setBassBoost(double level) => _bassBoost = level;
  void setVirtualizer(double level) => _virtualizer = level;
}
