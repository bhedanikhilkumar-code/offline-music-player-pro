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

  // Built-in theme images using network URLs for previews
  final List<Map<String, dynamic>> themeImages = [
    {
      'label': 'Custom',
      'category': 'All images',
      'icon': Icons.add_photo_alternate_outlined,
      'colors': [const Color(0xFF6C63FF), const Color(0xFF3D5AFE)],
    },

    // ── Nature ──
    {
      'label': 'Snowy Mountain',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Aurora Lights',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Night Mountain',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Forest Lake',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Forest',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Ocean',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Sunset',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Waterfall',
      'category': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1432405972618-c6b0cfba5428?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1432405972618-c6b0cfba5428?w=1080&h=1920&fit=crop',
    },

    // ── Pet ──
    {
      'label': 'Cute Puppy',
      'category': 'Pet',
      'imageUrl': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Border Collie',
      'category': 'Pet',
      'imageUrl': 'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Cute Cat',
      'category': 'Pet',
      'imageUrl': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Golden Retriever',
      'category': 'Pet',
      'imageUrl': 'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=1080&h=1920&fit=crop',
    },

    // ── Cartoon / Anime ──
    {
      'label': 'Anime Girl',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Anime City',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1580477667995-2b94f01c9516?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1580477667995-2b94f01c9516?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Night Sky Art',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Neon City',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Abstract Wave',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1550684376-efcbd6e3f031?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1550684376-efcbd6e3f031?w=1080&h=1920&fit=crop',
    },

    // ── Other ──
    {
      'label': 'Planet Earth',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'City Sunset',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Supercar',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Galaxy',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Concert',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Headphones',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Vinyl Record',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1539375665275-f9de415ef9ac?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1539375665275-f9de415ef9ac?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Skyscrapers',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Rain Drops',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1515694346937-94d85e39d29c?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1515694346937-94d85e39d29c?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Neon Flow',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1080&h=1920&fit=crop',
    },
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

                      // ─── Color Selection Section ───
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text('Theme Colors', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                      ),
                      _buildPremiumColorRow(context),
                      const SizedBox(height: 10),
                      _buildRegularColorRows(context),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                      const SizedBox(height: 8),

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

                      const SizedBox(height: 12),

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
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: displayedImages.length,
        itemBuilder: (context, index) {
          final item = displayedImages[index];
          final label = item['label'] as String;
          final isCustom = label == 'Custom';
          final hasImage = item.containsKey('imageUrl');
          final imageUrl = item['imageUrl'] as String?;
          final fullUrl = item['fullUrl'] as String?;
          final colors = item['colors'] as List<Color>? ?? [const Color(0xFF6C63FF), const Color(0xFF3D5AFE)];
          final icon = item['icon'] as IconData? ?? Icons.image_rounded;

          // Check if this theme is currently selected
          final isSelected = hasImage &&
              fullUrl != null &&
              themeProvider.backgroundImagePath == fullUrl;

          return GestureDetector(
            onTap: () {
              if (isCustom) {
                _pickCustomImage(context);
              } else if (hasImage && fullUrl != null) {
                context.read<ThemeProvider>().setBackgroundImage(fullUrl);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: Colors.lightBlueAccent, width: 2.5)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.lightBlueAccent.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)]
                    : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSelected ? 13.5 : 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── Background ──
                    if (isCustom)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors,
                          ),
                        ),
                        child: Column(
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
                        ),
                      )
                    else if (hasImage)
                      Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade900,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white54),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade900,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 28),
                              const SizedBox(height: 4),
                              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),

                    // ── Bottom vignette for label readability ──
                    if (!isCustom)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                            ),
                          ),
                        ),
                      ),

                    // ── Label ──
                    if (!isCustom)
                      Positioned(
                        bottom: 8, left: 8, right: 8,
                        child: Text(
                          label,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // ── Blue checkmark for selected theme ──
                    if (isSelected)
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 15),
                        ),
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
