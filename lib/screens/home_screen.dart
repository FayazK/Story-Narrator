import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/ui/app_colors.dart';
import '../utils/ui/responsive_sidebar.dart';
import '../utils/ui/content_container.dart';
import '../database/database_helper.dart';
import '../models/story.dart';
import '../components/home/story_list.dart';
import './settings_screen.dart';
import './create_story_screen.dart';
import './story_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Story> _stories = [];
  bool _isLoadingStories = false;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    if (mounted) {
      setState(() {
        _isLoadingStories = true;
      });
    }

    try {
      final stories = await _databaseHelper.getAllStories();

      if (mounted) {
        setState(() {
          _stories = stories;
          _isLoadingStories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stories: $e'),
            backgroundColor: AppColors.accent4,
          ),
        );
      }
    }
  }

  void _handleStorySelected(int storyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryEditScreen(storyId: storyId),
      ),
    ).then((_) => _loadStories()); // Reload stories when returning
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define sidebar width based on screen size
    // For small screens: 60px
    // For medium screens: 15% of screen width
    // For large screens: 260px max
    final double sidebarWidth;
    if (screenWidth < 800) {
      sidebarWidth = 60.0;
    } else if (screenWidth < 1200) {
      sidebarWidth = screenWidth * 0.18;
    } else {
      sidebarWidth = 260.0;
    }

    return Scaffold(
      body: Container(
        // Apply a subtle background gradient to the entire screen
        decoration: BoxDecoration(color: AppColors.bgSurface),
        child: Row(
          children: [
            // Responsive Sidebar
            ResponsiveSidebar(
              width: sidebarWidth,
              height: screenHeight,
              selectedIndex: _selectedNavIndex,
              onNavItemSelected: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
              onCreateStory: () {
                // Navigate to create story screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateStoryScreen(),
                  ),
                );
              },
              onSettings: () {
                // Navigate to settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            // Content Area
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // Build the main content area based on selected navigation item
  Widget _buildContent() {
    // For now, we just have the home content, but this can be expanded
    // to show different content based on _selectedNavIndex
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMyStoriesContent();
      case 2:
        return _buildCharactersContent();
      case 3:
        return _buildTemplatesContent();
      default:
        return _buildHomeContent();
    }
  }

  // Home dashboard content
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Top header area with gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: AppColors.softShadow,
            ),
            padding: const EdgeInsets.fromLTRB(40, 30, 40, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Story Narrator',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create, narrate, and bring your stories to life',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight.withValues(alpha: .9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'New Story',
                        onTap: () {
                          // Navigate to create story screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateStoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Recent',
                        onTap: () {
                          // TODO: Open recent stories
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionButton(
                        icon: Icons.help_outline,
                        label: 'Help',
                        onTap: () {
                          // TODO: Show help/tutorial
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main content area
        Positioned(
          top: 180,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent activity section
                _hasStories ? _buildRecentStories() : _buildEmptyState(),

                const SizedBox(height: 40),

                // Features grid section
                _buildFeaturesSection(),

                const SizedBox(height: 40),

                // Tips and tricks section
                _buildTipsSection(),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // Quick action button for header
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state widget shown when no stories exist
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.subtleShadow,
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: .8),
                  AppColors.primaryDark.withValues(alpha: .9),
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
              foreground:
                  Paint()
                    ..shader = LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
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

          // Action button
          ElevatedButton(
            onPressed: () {
              // Navigate to create story screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStoryScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Create New Story',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Features grid showing app capabilities
  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature Highlights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildFeatureCard(
              title: 'AI Story Generation',
              description:
                  'Use Gemini AI to generate compelling story ideas and scenes',
              icon: Icons.smart_toy_outlined,
              color: Colors.blue,
            ),
            _buildFeatureCard(
              title: 'Voice Narration',
              description:
                  'Convert your stories to audio using ElevenLabs text-to-speech',
              icon: Icons.record_voice_over,
              color: Colors.orange,
            ),
            _buildFeatureCard(
              title: 'Character Development',
              description:
                  'Create rich, detailed characters with diverse personalities',
              icon: Icons.people_outline,
              color: Colors.green,
            ),
            _buildFeatureCard(
              title: 'Scene Builder',
              description: 'Craft engaging scenes with vivid descriptions',
              icon: Icons.movie_outlined,
              color: Colors.purple,
            ),
            _buildFeatureCard(
              title: 'Story Templates',
              description:
                  'Use templates for various genres and story structures',
              icon: Icons.category_outlined,
              color: Colors.indigo,
            ),
            _buildFeatureCard(
              title: 'Export & Share',
              description:
                  'Export your stories in various formats for easy sharing',
              icon: Icons.ios_share_outlined,
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  // Individual feature card
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.subtleShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: .8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Tips and tricks section
  Widget _buildTipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: .05),
            AppColors.primaryLight.withValues(alpha: .15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Tips & Tricks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            'Create compelling characters by giving them flaws and conflicts',
          ),
          _buildTipItem(
            'Use the Gemini AI to expand on your ideas when you feel stuck',
          ),
          _buildTipItem(
            'Preview your narration with different voices before finalizing',
          ),
          _buildTipItem('Regularly save your work using the auto-save feature'),
        ],
      ),
    );
  }

  // Individual tip item
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recent stories grid (shown when the user has created stories)
  Widget _buildRecentStories() {
    final recentStories =
        _stories.take(3).toList(); // Show up to 3 recent stories

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Stories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedNavIndex = 1; // Switch to My Stories tab
                    });
                  },
                  icon: Icon(
                    Icons.view_list,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Recent stories list
          for (final story in recentStories)
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: AppColors.primary),
              ),
              title: Text(
                story.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle:
                  story.createdAt != null
                      ? Text('Created: ${story.createdAt}')
                      : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _handleStorySelected(story.id!),
            ),

          // View all button at the bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedNavIndex = 1; // Switch to My Stories tab
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: .1),
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('View All Stories'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // My Stories content section
  Widget _buildMyStoriesContent() {
    return ContentContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Stories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateStoryScreen(),
                      ),
                    ).then(
                      (_) => _loadStories(),
                    ); // Reload stories when returning
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Story'),
                ),
              ],
            ),
          ),

          // Story list
          Expanded(
            child:
                _isLoadingStories
                    ? const Center(child: CircularProgressIndicator())
                    : StoryList(
                      stories: _stories,
                      onStorySelected: _handleStorySelected,
                    ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCharactersContent() {
    return Center(
      child: Text(
        'Characters Content',
        style: TextStyle(fontSize: 24, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildTemplatesContent() {
    return Center(
      child: Text(
        'Templates Content',
        style: TextStyle(fontSize: 24, color: AppColors.textDark),
      ),
    );
  }

  // Check if there are any stories
  bool get _hasStories => _stories.isNotEmpty;
}
