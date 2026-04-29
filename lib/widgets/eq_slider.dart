import 'package:flutter/material.dart';

class EqSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double>? onChanged;
  final bool enabled;

  const EqSlider({
    super.key,
    required this.value,
    this.min = -10,
    this.max = 10,
    required this.label,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${value.toStringAsFixed(0)}dB',
            style: TextStyle(color: Colors.white70, fontSize: 10)),
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
                disabledActiveTrackColor: Colors.white24,
                disabledInactiveTrackColor: Colors.white12,
                disabledThumbColor: Colors.white38,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
