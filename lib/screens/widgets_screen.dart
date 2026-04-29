import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/theme_provider.dart';

class WidgetInfo {
  final String name;
  final String description;
  final String size;
  final IconData icon;
  final List<Color> gradient;

  const WidgetInfo({
    required this.name,
    required this.description,
    required this.size,
    required this.icon,
    required this.gradient,
  });
}

class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  static const List<WidgetInfo> _widgets = [
    WidgetInfo(
      name: 'Mini Controls',
      description: 'Compact strip with prev, play/pause, next and scrolling song title. Perfect for the top of your home screen.',
      size: '4 × 1',
      icon: Icons.view_stream_rounded,
      gradient: [Color(0xFFFF6B35), Color(0xFFFF8F65)],
    ),
    WidgetInfo(
      name: 'Now Playing',
      description: 'Shows album art, song title, artist name and full playback controls in a sleek card design.',
      size: '4 × 2',
      icon: Icons.album_rounded,
      gradient: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    ),
    WidgetInfo(
      name: 'Full Player',
      description: 'Large widget with album art, song info, playing status indicator and all playback controls.',
      size: '4 × 3',
      icon: Icons.music_note_rounded,
      gradient: [Color(0xFF00B894), Color(0xFF55EFC4)],
    ),
    WidgetInfo(
      name: 'Quick Play',
      description: 'Minimal square widget with a big play/pause button and current song title. One tap to play.',
      size: '2 × 2',
      icon: Icons.play_circle_outline_rounded,
      gradient: [Color(0xFFE84393), Color(0xFFFD79A8)],
    ),
    WidgetInfo(
      name: 'Recent Playlist',
      description: 'Shows your last played song with a play button and status indicator. Great for quick resume.',
      size: '4 × 2',
      icon: Icons.queue_music_rounded,
      gradient: [Color(0xFF0984E3), Color(0xFF74B9FF)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text('Home Screen Widgets', style: AppTextStyles.headingMedium),
                      ],
                    ),
                  ),

                  // Info card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: themeProvider.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.widgets_rounded, color: themeProvider.primaryColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add widgets to your home screen',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Long-press your home screen → Widgets → Music Player',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Widget list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _widgets.length,
                      itemBuilder: (context, index) {
                        return _buildWidgetCard(context, _widgets[index], index, themeProvider.primaryColor);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWidgetCard(BuildContext context, WidgetInfo widget, int index, Color primaryColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.size,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
