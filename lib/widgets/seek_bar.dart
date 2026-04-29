import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.position.inMilliseconds.toDouble();
    final max = widget.duration.inMilliseconds.toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Slider(
        value: value.clamp(0, max > 0 ? max : 1),
        max: max > 0 ? max : 1,
        activeColor: Colors.white,
        inactiveColor: Colors.white24,
        onChanged: (v) {
          setState(() => _dragValue = v);
          widget.onChanged?.call(Duration(milliseconds: v.round()));
        },
        onChangeEnd: (v) {
          _dragValue = null;
          widget.onChangeEnd?.call(Duration(milliseconds: v.round()));
        },
      ),
    );
  }
}
