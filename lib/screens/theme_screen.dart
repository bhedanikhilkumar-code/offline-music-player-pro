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

  // Built-in theme images
  final List<Map<String, dynamic>> themeImages = [
    {'label': 'Custom', 'category': 'All images', 'icon': Icons.add_photo_alternate_outlined, 'colors': [const Color(0xFF6C63FF), const Color(0xFF3D5AFE)]},
    
    // Nature
    {'label': 'Snowy Mountain', 'category': 'Nature', 'assetPath': 'assets/images/themes/nature_mountain.png', 'isUnique': true},
    {'label': 'Aurora Lights', 'category': 'Nature', 'assetPath': 'assets/images/themes/nature_aurora.png', 'isUnique': true},
    {'label': 'Night Mountain', 'category': 'Nature', 'assetPath': 'assets/images/themes/nature_night_mountain.png', 'isUnique': true},
    {'label': 'Forest Lake', 'category': 'Nature', 'assetPath': 'assets/images/themes/theme_nature.png', 'isUnique': true},
    {'label': 'Forest', 'category': 'Nature', 'colors': [const Color(0xFF1B5E20), const Color(0xFF66BB6A)]},
    {'label': 'Ocean', 'category': 'Nature', 'colors': [const Color(0xFF006064), const Color(0xFF00E5FF)]},
    {'label': 'Sunset', 'category': 'Nature', 'colors': [const Color(0xFFBF360C), const Color(0xFFFF9100)]},

    // Pet
    {'label': 'Cute Puppy', 'category': 'Pet', 'assetPath': 'assets/images/themes/theme_pet.png', 'isUnique': true},
    {'label': 'Border Collie', 'category': 'Pet', 'assetPath': 'assets/images/themes/pet_collie.png', 'isUnique': true},

    // Cartoon
    {'label': 'Anime Girl', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_anime_girl.png', 'isUnique': true},
    {'label': 'Silver Anime', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_anime_silver.png', 'isUnique': true},
    {'label': 'Neon Anime', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_anime_girl2.png', 'isUnique': true},
    {'label': 'Anime City', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/theme_cartoon.png', 'isUnique': true},
    {'label': 'Windmill', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_windmill.png', 'isUnique': true},
    {'label': 'Night Sky', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_nightsky.png', 'isUnique': true},
    {'label': 'Wave Art', 'category': 'Cartoon', 'assetPath': 'assets/images/themes/cartoon_mountain.png', 'isUnique': true},

    // Other
    {'label': 'Planet Earth', 'category': 'Other', 'assetPath': 'assets/images/themes/others_earth.png', 'isUnique': true},
    {'label': 'City Sunset', 'category': 'Other', 'assetPath': 'assets/images/themes/others_city_sunset.png', 'isUnique': true},
    {'label': 'Tech Abstract', 'category': 'Other', 'assetPath': 'assets/images/themes/others_tech.png', 'isUnique': true},
    {'label': 'Skyscrapers', 'category': 'Other', 'assetPath': 'assets/images/themes/others_skyscrapers.png', 'isUnique': true},
    {'label': 'Luxury Office', 'category': 'Other', 'assetPath': 'assets/images/themes/others_office.png', 'isUnique': true},
    {'label': 'Supercar', 'category': 'Other', 'assetPath': 'assets/images/themes/others_supercar.png', 'isUnique': true},
    {'label': 'Galaxy', 'category': 'Other', 'assetPath': 'assets/images/themes/others_galaxy.png', 'isUnique': true},
    {'label': 'Rain Drops', 'category': 'Other', 'assetPath': 'assets/images/themes/others_raindrops.png', 'isUnique': true},
    {'label': 'Concert', 'category': 'Other', 'assetPath': 'assets/images/themes/others_concert.png', 'isUnique': true},
    {'label': 'Vinyl Record', 'category': 'Other', 'assetPath': 'assets/images/themes/others_vinyl.png', 'isUnique': true},
    {'label': 'Headphones', 'category': 'Other', 'assetPath': 'assets/images/themes/others_headphones.png', 'isUnique': true},
    {'label': 'Skateboard', 'category': 'Other', 'assetPath': 'assets/images/themes/others_skateboard.png', 'isUnique': true},
    {'label': 'Neon Flow', 'category': 'Other', 'assetPath': 'assets/images/themes/theme_other.png', 'isUnique': true},
  ];

  @override
  void initState() {
    super.initState();
    _imageTabController = TabController(length: imageCategories.length, vsync: this);
    _imageTabController.addListener(() {
      setState(() {}); // Rebuild grid when tab changes
    });
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
            child: Stack(
              children: [
                // Dark overlay for better readability
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            Text(AppStrings.skinTheme, style: AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
                          ],
                        ),
                      ),
                      
                      // Tabs
                      TabBar(
                        controller: _imageTabController,
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: AppTextStyles.tabLabel.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        dividerColor: Colors.transparent,
                        tabs: imageCategories.map((cat) => Tab(text: cat)).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: _buildImageGrid(context, themeProvider),
                      ),
                    ],
                  ),
                ),
              ],
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
  Widget _buildImageGrid(BuildContext context, ThemeProvider themeProvider) {
    final selectedCategory = imageCategories[_imageTabController.index];
    
    // Filter images based on tab
    final displayedImages = themeImages.where((item) {
      if (item['label'] == 'Custom') return true; // Always show Custom
      if (selectedCategory == 'All images') return true;
      return item['category'] == selectedCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayedImages.length,
        itemBuilder: (context, index) {
          final item = displayedImages[index];
          final hasAsset = item.containsKey('assetPath');
          final label = item['label'] as String;
          final isCustom = label == 'Custom';
          final colors = item['colors'] as List<Color>? ?? [Colors.blueGrey, Colors.black87];
          final icon = item['icon'] as IconData? ?? Icons.image_rounded;
          final isSelected = themeProvider.backgroundImagePath == (hasAsset ? item['assetPath'] : null) && !isCustom;

          return GestureDetector(
            onTap: () {
              if (isCustom) {
                _pickCustomImage(context);
              } else if (hasAsset) {
                context.read<ThemeProvider>().setBackgroundImage(item['assetPath']);
              }
            },
            child: Stack(
              children: [
                Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: hasAsset ? null : LinearGradient(
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
                            if (hasAsset)
                              Image.asset(
                                item['assetPath'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                              )
                            else
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
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                  if (isSelected)
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                ],
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
