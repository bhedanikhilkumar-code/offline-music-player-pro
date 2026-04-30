import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/sleep_timer_provider.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SleepTimerScreen(),
    );
  }

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  @override
  void initState() {
    super.initState();
    _hoursController = FixedExtentScrollController(initialItem: 0);
    _minutesController = FixedExtentScrollController(initialItem: 0);
    _secondsController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _setPreset(int minutes) {
    setState(() {
      _selectedHours = minutes ~/ 60;
      _selectedMinutes = minutes % 60;
      _selectedSeconds = 0;
    });
    _hoursController.animateToItem(_selectedHours, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _minutesController.animateToItem(_selectedMinutes, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _secondsController.animateToItem(_selectedSeconds, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget _buildPicker(int count, int selectedValue, FixedExtentScrollController controller, ValueChanged<int> onChanged) {
    return SizedBox(
      width: 70,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 54,
        perspective: 0.005,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            final isSelected = index == selectedValue;
            return Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 66,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: isSelected ? 34 : 26,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<SleepTimerProvider>();
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: const Color(0xFF282828).withOpacity(0.95),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stop music after', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 40),
              
              if (timer.isRunning)
                Center(
                  child: Column(
                    children: [
                      Text(timer.remainingFormatted, style: AppTextStyles.headingLarge.copyWith(fontSize: 56, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Music will stop automatically', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              else
                // Time Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPicker(24, _selectedHours, _hoursController, (v) => setState(() => _selectedHours = v)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    _buildPicker(60, _selectedMinutes, _minutesController, (v) => setState(() => _selectedMinutes = v)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    _buildPicker(60, _selectedSeconds, _secondsController, (v) => setState(() => _selectedSeconds = v)),
                  ],
                ),
              
              const SizedBox(height: 40),
              
              if (!timer.isRunning)
                // Presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [15, 30, 45, 60].map((mins) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          onTap: () => _setPreset(mins),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.alarm_rounded, color: Colors.white54, size: 22),
                                const SizedBox(height: 4),
                                Text('${mins}m', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
              const SizedBox(height: 40),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (timer.isRunning) timer.cancelTimer();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide.none,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Text('CANCEL', style: AppTextStyles.buttonText.copyWith(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!timer.isRunning)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedHours > 0 || _selectedMinutes > 0 || _selectedSeconds > 0) {
                            timer.startTimer(
                              (_selectedHours * 60) + _selectedMinutes,
                              seconds: _selectedSeconds,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF3F6A8E), // Blue from screenshot
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          elevation: 0,
                        ),
                        child: Text('START', style: AppTextStyles.buttonText),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
