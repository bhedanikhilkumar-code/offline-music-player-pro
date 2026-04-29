import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/theme_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});
  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> with SingleTickerProviderStateMixin {
  late TabController _imageTabController;
  
  // Premium colors (top row with crown badges)
  static const List<Color> premiumColors = [
    Color(0xFF4A148C), // Deep purple
    Color(0xFF6D4C41), // Brown
    Color(0xFF00695C), // Teal dark
    Color(0xFF4A0072), // Purple
  ];

  // Regular colors (rows without crown)
  static const List<Color> regularColors = [
    Color(0xFF283593), // Indigo
    Color(0xFF1565C0), // Blue
    Color(0xFF00ACC1), // Cyan
    Color(0xFFD81B60), // Pink
    Color(0xFFFF8C00), // Orange
    Color(0xFFE53935), // Red
    Color(0xFFD500F9), // Magenta
  ];

  // All image categories
  static const List<String> imageCategories = ['All images', 'Nature', 'Pet', 'Cartoon', 'Other'];

  // Built-in theme images with placeholder colors for gallery
  final List<Map<String, dynamic>> themeImages = [
    {'label': 'Custom', 'icon': Icons.add_photo_alternate_outlined, 'colors': [const Color(0xFF6C63FF), const Color(0xFF3D5AFE)]},
    {'label': 'Ocean Glass', 'colors': [Color(0xFF1A1A2E), Color(0xFF0F3460)], 'isUnique': true},
    {'label': 'Cyber Neon', 'colors': [Color(0xFF00F260), Color(0xFF0575E6)], 'isUnique': true},
    {'label': 'Neon Pink', 'colors': [Color(0xFFFF00CC), Color(0xFF333399)], 'isUnique': true},
    {'label': 'Amethyst', 'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)], 'isUnique': true},
    {'label': 'Midnight', 'colors': [Color(0xFF434343), Color(0xFF000000)], 'isUnique': true},
    {'label': 'Earth', 'colors': [const Color(0xFF0D47A1), const Color(0xFF00BCD4)]},
    {'label': 'Anime', 'colors': [const Color(0xFF7C4DFF), const Color(0xFF448AFF)]},
    {'label': 'Car', 'colors': [const Color(0xFFFF1744), const Color(0xFFFF6D00)]},
    {'label': 'Galaxy', 'colors': [const Color(0xFF311B92), const Color(0xFFE040FB)]},
    {'label': 'Mountain', 'colors': [const Color(0xFF01579B), const Color(0xFF4FC3F7)]},
    {'label': 'Forest', 'colors': [const Color(0xFF1B5E20), const Color(0xFF66BB6A)]},
    {'label': 'Ocean', 'colors': [const Color(0xFF006064), const Color(0xFF00E5FF)]},
    {'label': 'Sunset', 'colors': [const Color(0xFFBF360C), const Color(0xFFFF9100)]},
  ];

  @override
  void initState() {
    super.initState();
    _imageTabController = TabController(length: imageCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _imageTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          body: Container(
            decoration: themeProvider.backgroundDecoration,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Text(AppStrings.skinTheme, style: AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Color Section ───
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text('Color', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          _buildPremiumColorRow(context),
                          const SizedBox(height: 14),
                          _buildRegularColorRows(context),
                          const SizedBox(height: 24),

                          // ─── Image Theme Section ───
                          TabBar(
                            controller: _imageTabController,
                            isScrollable: true,
                            indicatorColor: Colors.white,
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white54,
                            labelStyle: AppTextStyles.tabLabel.copyWith(fontSize: 13),
                            tabAlignment: TabAlignment.start,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            dividerColor: Colors.transparent,
                            tabs: imageCategories.map((cat) => Tab(text: cat)).toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildImageGrid(context),
                          const SizedBox(height: 32),
                        ],
                      ),
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

  // ─── Premium Colors Row (with crown icon) ───
  Widget _buildPremiumColorRow(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: premiumColors.asMap().entries.map((entry) {
              final color = entry.value;
              final isSelected = theme.primaryColor.value == color.value;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => theme.setPrimaryColor(color),
                  child: SizedBox(
                    width: 60, height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 56, height: 56,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : color.withOpacity(0.4),
                              width: isSelected ? 2.5 : 2,
                            ),
                            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)] : null,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                          ),
                        ),
                        // Crown badge
                        Positioned(
                          top: 0,
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: 18,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ─── Regular Color Rows ───
  Widget _buildRegularColorRows(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16, runSpacing: 14,
            children: regularColors.map((color) {
              final isSelected = theme.primaryColor.value == color.value;
              return GestureDetector(
                onTap: () => theme.setPrimaryColor(color),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 14, spreadRadius: 2)]
                        : [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ─── Image Grid ───
  Widget _buildImageGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: themeImages.length,
        itemBuilder: (context, index) {
          final item = themeImages[index];
          final colors = item['colors'] as List<Color>;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData?;
          final isCustom = label == 'Custom';

          return GestureDetector(
            onTap: () {
              if (isCustom) {
                _pickCustomImage(context);
              } else {
                context.read<ThemeProvider>().setGradient(colors);
                context.read<ThemeProvider>().setPrimaryColor(colors[0]);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: isCustom
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Gradient background as placeholder for real images
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                  colors: [colors[0], colors[1].withOpacity(0.8)],
                                ),
                              ),
                              child: Icon(
                                _getImageIcon(label),
                                size: 40, color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            if (item['isUnique'] == true)
                              Positioned(
                                top: 8, right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('UNIQUE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            // Subtle bottom vignette
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8, left: 8,
                              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }

  IconData _getImageIcon(String label) {
    switch (label) {
      case 'Earth': return Icons.public_rounded;
      case 'Anime': return Icons.face_rounded;
      case 'Car': return Icons.directions_car_rounded;
      case 'Galaxy': return Icons.auto_awesome;
      case 'Mountain': return Icons.terrain_rounded;
      case 'Forest': return Icons.park_rounded;
      case 'Ocean': return Icons.water_rounded;
      case 'Sunset': return Icons.wb_twilight_rounded;
      default: return Icons.image_rounded;
    }
  }

  Future<void> _pickCustomImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        if (context.mounted) {
          context.read<ThemeProvider>().setBackgroundImage(result.files.single.path!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom theme applied!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
