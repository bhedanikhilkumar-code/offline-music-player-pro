import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';
import '../models/folder_model.dart';

class FolderTile extends StatelessWidget {
  final FolderModel folder;
  final VoidCallback onTap;

  const FolderTile({super.key, required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDarkLight,
        ),
        child: const Icon(Icons.folder_rounded, color: AppColors.accentAmber),
      ),
      title: Text(folder.name, style: AppTextStyles.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${folder.songCount} songs', style: AppTextStyles.songSubtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
