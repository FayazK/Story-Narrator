import 'package:flutter/material.dart';
import '../utils/ui/app_colors.dart';
import '../utils/ui/responsive_sidebar.dart';
import '../utils/ui/content_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define sidebar width based on screen size
    // For small screens: 60px
    // For medium screens: 15% of screen width
    // For large screens: 220px max
    final double sidebarWidth;
    if (screenWidth < 600) {
      sidebarWidth = 60.0;
    } else if (screenWidth < 1200) {
      sidebarWidth = screenWidth * 0.15;
    } else {
      sidebarWidth = 220.0;
    }
    
    return Scaffold(
      body: Container(
        // Apply a subtle background gradient to the entire screen
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Row(
          children: [
            // Responsive Sidebar
            ResponsiveSidebar(
              width: sidebarWidth,
              height: screenHeight,
              onCreateStory: () {
                // TODO: Navigate to create story screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create Story button pressed')),
                );
              },
              onSettings: () {
                // TODO: Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings button pressed')),
                );
              },
            ),
            
            // Content Area
            Expanded(
              child: ContentContainer(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Empty state illustration/icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.7),
                              AppColors.primaryDark.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppColors.softShadow,
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Empty state text
                      Text(
                        'Create your first story',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primary,
                              ],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Text(
                          'Click on "Create Story" to begin your narrative journey. '
                          'You\'ll be able to craft characters, scenes, and bring your story to life.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMedium,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Visual indicator to direct user to the sidebar button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: AppColors.primary.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Use the sidebar to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMedium.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
