import 'package:flutter/material.dart';
import '../../models/story_scene.dart';
import '../../utils/ui/app_colors.dart';

class ScenesSidebar extends StatelessWidget {
  final List<StoryScene> scenes;
  final int selectedSceneIndex;
  final Function(int) onSceneSelected;

  const ScenesSidebar({
    super.key,
    required this.scenes,
    required this.selectedSceneIndex,
    required this.onSceneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Scenes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            
            // Scene List
            Expanded(
              child: ListView.builder(
                itemCount: scenes.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  final isSelected = index == selectedSceneIndex;
                  
                  return _SceneListItem(
                    scene: scene,
                    isSelected: isSelected,
                    onTap: () => onSceneSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneListItem extends StatelessWidget {
  final StoryScene scene;
  final bool isSelected;
  final VoidCallback onTap;

  const _SceneListItem({
    required this.scene,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNarration = scene.narration != null;
    final characterCount = scene.characterScripts.length;
    final audioCount = scene.scripts
        .where((script) => script.voiceoverPath != null && script.voiceoverPath!.isNotEmpty)
        .length;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.3) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scene Number
            Text(
              'Scene ${scene.sceneNumber}',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            
            // Scene metadata indicators
            Row(
              children: [
                if (hasNarration)
                  _StatusIndicator(
                    icon: Icons.book,
                    color: AppColors.accent1,
                    tooltip: 'Has narration',
                  ),
                if (characterCount > 0)
                  _StatusIndicator(
                    icon: Icons.person,
                    color: AppColors.accent2,
                    tooltip: '$characterCount character(s)',
                    count: characterCount,
                  ),
                if (audioCount > 0)
                  _StatusIndicator(
                    icon: Icons.volume_up,
                    color: AppColors.accent3,
                    tooltip: '$audioCount audio file(s)',
                    count: audioCount,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final int? count;

  const _StatusIndicator({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: tooltip,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            if (count != null)
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
