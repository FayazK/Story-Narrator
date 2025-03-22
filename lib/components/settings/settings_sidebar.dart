import 'package:flutter/material.dart';
import '../../utils/ui/app_colors.dart';

class SettingsSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final VoidCallback onSavePressed;
  final bool hasChanges;

  const SettingsSidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onSavePressed,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSettingNavItem(
            'API Configuration',
            Icons.api,
            index: 0,
            isSelected: selectedIndex == 0,
          ),
          _buildSettingNavItem(
            'Voice Settings',
            Icons.record_voice_over,
            index: 1,
            isSelected: selectedIndex == 1,
          ),
          _buildSettingNavItem(
            'Appearance',
            Icons.color_lens_outlined,
            index: 2,
            isSelected: selectedIndex == 2,
          ),
          _buildSettingNavItem(
            'Keyboard Shortcuts',
            Icons.keyboard,
            index: 3,
            isSelected: selectedIndex == 3,
          ),
          _buildSettingNavItem(
            'Storage Management',
            Icons.storage,
            index: 4,
            isSelected: selectedIndex == 4,
          ),
          _buildSettingNavItem(
            'About',
            Icons.info_outline,
            index: 5,
            isSelected: selectedIndex == 5,
          ),
          const Spacer(),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: hasChanges ? onSavePressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 18),
                  SizedBox(width: 8),
                  Text('Save Changes'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build settings navigation item
  Widget _buildSettingNavItem(
    String title, 
    IconData icon, 
    {required int index, required bool isSelected}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onIndexChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sidebarSelected.withOpacity(0.2) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.sidebarText,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.sidebarText,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
