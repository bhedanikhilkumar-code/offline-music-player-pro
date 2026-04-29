import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../providers/sleep_timer_provider.dart';

class SleepTimerScreen extends StatelessWidget {
  const SleepTimerScreen({super.key});

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
          child: Consumer<SleepTimerProvider>(
            builder: (context, timer, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        Text(AppStrings.sleepTimer, style: AppTextStyles.headingMedium),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (timer.isRunning) ...[
                            Container(
                              width: 180, height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(timer.remainingFormatted, style: AppTextStyles.headingLarge),
                                    Text(AppStrings.timerRunning, style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: () => timer.cancelTimer(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(AppStrings.cancelTimer, style: AppTextStyles.buttonText),
                              ),
                            ),
                          ] else ...[
                            Icon(Icons.bedtime_rounded, size: 64, color: Theme.of(context).primaryColor),
                            const SizedBox(height: 16),
                            Text('Set sleep timer', style: AppTextStyles.headingSmall),
                            const SizedBox(height: 8),
                            Text('Music will stop after the selected time', style: AppTextStyles.bodySmall),
                            const SizedBox(height: 32),
                            Wrap(
                              spacing: 12, runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: AppConstants.sleepTimerPresets.map((minutes) {
                                return SizedBox(
                                  width: 100, height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => timer.startTimer(minutes),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.cardDark,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text('$minutes min', style: AppTextStyles.bodyMedium),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => _showCustomTimerDialog(context, timer),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(AppStrings.customTimer, style: AppTextStyles.bodyMedium),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCustomTimerDialog(BuildContext context, SleepTimerProvider timer) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(AppStrings.customTimer, style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Minutes',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text);
              if (minutes != null && minutes > 0) {
                timer.startTimer(minutes);
                Navigator.pop(context);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
