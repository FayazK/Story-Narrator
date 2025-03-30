import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A responsive sidebar that adjusts based on screen size, designed for desktop UIs
class ResponsiveSidebar extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onCreateStory;
  final VoidCallback onSettings;
  final int selectedIndex;
  final Function(int)? onNavItemSelected;

  const ResponsiveSidebar({
    super.key,
    required this.width,
    required this.height,
    required this.onCreateStory,
    required this.onSettings,
    this.selectedIndex = 0,
    this.onNavItemSelected,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  // Track which item is being hovered
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    // Determine if we're in compact mode (width < 130px)
    final bool isCompact = widget.width < 220;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: AppColors.sidebarGradient,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo/Title section
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: AppColors.textLight,
                  size: 28,
                ),
                if (!isCompact) ...[  
                  const SizedBox(width: 12),
                  Text(
                    'Story Narrator',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // Create Story Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCreateButton(isCompact),
          ),

          const SizedBox(height: 32),
          
          // Navigation section
          _buildNavigationSection(isCompact),
          
          // Fill the space between nav items and settings
          const Spacer(),

          // Settings Button at the bottom
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
            ),
            child: _buildNavItem(
              index: 99, // Special index for settings
              icon: Icons.settings,
              label: 'Settings',
              isSelected: false,
              isCompact: isCompact,
              onTap: widget.onSettings,
            ),
          ),
        ],
      ),
    );
  }
  
  // Create button with proper styling for desktop
  Widget _buildCreateButton(bool isCompact) {
    return ElevatedButton(
      onPressed: widget.onCreateStory,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isCompact ? 12 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 18),
          if (!isCompact) ...[  
            const SizedBox(width: 8),
            const Text(
              'Create Story',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
  
  // Navigation items section
  Widget _buildNavigationSection(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label (only shown in expanded mode)
        if (!isCompact)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              'NAVIGATE',
              style: TextStyle(
                color: AppColors.sidebarText.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
        // Home / Dashboard
        _buildNavItem(
          index: 0,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          isSelected: widget.selectedIndex == 0,
          isCompact: isCompact,
          onTap: () => widget.onNavItemSelected?.call(0),
        ),
        
        // My Stories
        _buildNavItem(
          index: 1,
          icon: Icons.book_outlined,
          activeIcon: Icons.book,
          label: 'My Stories',
          isSelected: widget.selectedIndex == 1,
          isCompact: isCompact,
          onTap: () => widget.onNavItemSelected?.call(1),
        ),
        
        // Characters
        _buildNavItem(
          index: 2,
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: 'Characters',
          isSelected: widget.selectedIndex == 2,
          isCompact: isCompact,
          onTap: () => widget.onNavItemSelected?.call(2),
        ),
        
        // Templates
        _buildNavItem(
          index: 3,
          icon: Icons.category_outlined,
          activeIcon: Icons.category,
          label: 'Templates',
          isSelected: widget.selectedIndex == 3,
          isCompact: isCompact,
          onTap: () => widget.onNavItemSelected?.call(3),
        ),
      ],
    );
  }
  
  // Individual navigation item
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required bool isSelected,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    final bool isHovered = _hoveredIndex == index;
    final IconData iconToShow = isSelected ? (activeIcon ?? icon) : icon;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isCompact ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.sidebarSelected.withOpacity(0.2)
                : isHovered 
                    ? AppColors.sidebarHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                iconToShow,
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.sidebarText,
                size: 20,
              ),
              if (!isCompact) ...[  
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.primary
                        : AppColors.sidebarText,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
