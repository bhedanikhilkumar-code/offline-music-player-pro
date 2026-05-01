import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../providers/theme_provider.dart';
import '../services/theme_cache_service.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});
  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> with SingleTickerProviderStateMixin {
  late TabController _imageTabController;
  final ThemeCacheService _cacheService = ThemeCacheService.instance;
  bool _isCachingAll = false;
  int _cachedCount = 0;
  int _totalCount = 0;

  // All theme colors in a single scrollable row
  static const List<Color> themeColors = [
    Color(0xFF4A148C), // Deep purple
    Color(0xFF6D4C41), // Brown
    Color(0xFF00695C), // Teal dark
    Color(0xFF4A0072), // Purple
    Color(0xFF283593), // Indigo
    Color(0xFF1565C0), // Blue
    Color(0xFF0097A7), // Cyan dark
    Color(0xFF00ACC1), // Cyan
    Color(0xFF00BCD4), // Cyan light
    Color(0xFFD81B60), // Pink
    Color(0xFFE91E63), // Pink light
    Color(0xFFFF8C00), // Orange
    Color(0xFFFF5722), // Deep orange
    Color(0xFFE53935), // Red
    Color(0xFFD500F9), // Magenta
    Color(0xFF9C27B0), // Purple medium
    Color(0xFF2E7D32), // Green
    Color(0xFF43A047), // Green light
    Color(0xFF00897B), // Teal
    Color(0xFF3949AB), // Indigo medium
    Color(0xFF5C6BC0), // Indigo light
    Color(0xFF1E88E5), // Blue medium
    Color(0xFF039BE5), // Light blue
    Color(0xFFFDD835), // Yellow
    Color(0xFFFFB300), // Amber
    Color(0xFF8D6E63), // Brown light
    Color(0xFF546E7A), // Blue grey
    Color(0xFF37474F), // Dark grey blue
    Color(0xFF212121), // Almost black
    Color(0xFFBDBDBD), // Light grey
  ];

  // All image categories
  static const List<String> imageCategories = ['All images', 'Nature', 'Pet', 'Cartoon', 'Girls', 'Superhero', 'Space', 'Other'];

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
      'imageUrl': 'https://images.unsplash.com/photo-1494472155656-f34e81b17ddc?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1494472155656-f34e81b17ddc?w=1080&h=1920&fit=crop',
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
      'imageUrl': 'https://images.unsplash.com/photo-1428592953211-077101b2021b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1428592953211-077101b2021b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Neon Flow',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'BMW',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Thar',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=1080&h=1920&fit=crop',
    },

    // ── Space ──
    {
      'label': 'Nebula',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1462332420958-a05d1e002413?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1462332420958-a05d1e002413?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Mars Surface',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Astronaut',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Milky Way',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Saturn Rings',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1614732414444-096e5f1122d5?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1614732414444-096e5f1122d5?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Space Station',
      'category': 'Space',
      'imageUrl': 'https://images.unsplash.com/photo-1454789548928-9efd52dc4031?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1454789548928-9efd52dc4031?w=1080&h=1920&fit=crop',
    },

    // ── Girls ──
    {
      'label': 'Japanese Girl',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Kimono Beauty',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Tokyo Girl',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Fashion Model',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Pink Aesthetic',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Neon Girl',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1526510747491-58f928ec870f?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1526510747491-58f928ec870f?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Sakura Girl',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Red Dress',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Beach Girl',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1504703395950-b89145a5425b?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1504703395950-b89145a5425b?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Portrait Beauty',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Golden Hour',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Street Style',
      'category': 'Girls',
      'imageUrl': 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=1080&h=1920&fit=crop',
    },

    // ── Superhero ──
    {
      'label': 'Iron Suit',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1608889476561-6242cfdbf622?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1608889476561-6242cfdbf622?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Dark Knight',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Spider Hero',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1604200213928-ba3cf4fc8436?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1604200213928-ba3cf4fc8436?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Star Warrior',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Shield Hero',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1569003339405-ea396a5a8a90?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1569003339405-ea396a5a8a90?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Cyber Warrior',
      'category': 'Superhero',
      'imageUrl': 'https://images.unsplash.com/photo-1560343090-f0409e92791a?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1560343090-f0409e92791a?w=1080&h=1920&fit=crop',
    },

    // ── More Cartoon / Anime ──
    {
      'label': 'Anime Warrior',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1613376023733-0a73315d9b06?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1613376023733-0a73315d9b06?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Manga Art',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1560972550-aba3456b5564?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1560972550-aba3456b5564?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Cosplay',
      'category': 'Cartoon',
      'imageUrl': 'https://images.unsplash.com/photo-1601814933824-fd0b574dd592?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1601814933824-fd0b574dd592?w=1080&h=1920&fit=crop',
    },

    // ── More Other ──
    {
      'label': 'Sports Car',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Motorbike',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'Gaming Setup',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=1080&h=1920&fit=crop',
    },
    {
      'label': 'DJ Console',
      'category': 'Other',
      'imageUrl': 'https://images.unsplash.com/photo-1563330232-57114bb0823c?w=400&h=600&fit=crop',
      'fullUrl': 'https://images.unsplash.com/photo-1563330232-57114bb0823c?w=1080&h=1920&fit=crop',
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
                      _buildColorRow(context),
                      const SizedBox(height: 8),
                      // Download All for Offline button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isCachingAll ? null : _cacheAllThemes,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.07),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCachingAll ? Icons.downloading_rounded : Icons.download_for_offline_rounded,
                                    color: Colors.lightBlueAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCachingAll
                                        ? 'Downloading... $_cachedCount/$_totalCount'
                                        : 'Download All for Offline',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  // ─── Horizontally Scrollable Color Row ───
  Widget _buildColorRow(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: themeColors.length,
            itemBuilder: (context, index) {
              final color = themeColors[index];
              final isSelected = theme.primaryColor.value == color.value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => theme.setPrimaryColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: isSelected ? Border.all(color: Colors.white, width: 2.5) : Border.all(color: color.withOpacity(0.4), width: 1.5),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
                          : [BoxShadow(color: color.withOpacity(0.25), blurRadius: 4)],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              );
            },
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
                // Also cache the thumbnail for offline grid display
                if (imageUrl != null) {
                  _cacheService.cacheImage(imageUrl);
                }
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
                      Builder(
                        builder: (context) {
                          final cachedPath = _cacheService.getCachedPath(imageUrl!);
                          if (cachedPath != null) {
                            return Image.file(
                              File(cachedPath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade900,
                                child: const Icon(Icons.broken_image_rounded, color: Colors.white38, size: 28),
                              ),
                            );
                          }
                          return Image.network(
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
                          );
                        },
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

  Future<void> _cacheAllThemes() async {
    final urls = <String>[];
    for (final item in themeImages) {
      if (item.containsKey('imageUrl')) urls.add(item['imageUrl'] as String);
      if (item.containsKey('fullUrl')) urls.add(item['fullUrl'] as String);
    }

    setState(() {
      _isCachingAll = true;
      _totalCount = urls.length;
      _cachedCount = 0;
    });

    await _cacheService.cacheImages(urls, onProgress: (cached, total) {
      if (mounted) {
        setState(() => _cachedCount = cached);
      }
    });

    if (mounted) {
      setState(() => _isCachingAll = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All themes downloaded for offline use! ✅'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
