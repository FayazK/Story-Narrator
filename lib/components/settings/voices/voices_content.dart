// lib/components/settings/voices/voices_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/ui/app_colors.dart';
import '../../../providers/shared_voices_provider.dart';
import 'voice_card.dart';

class VoicesContent extends ConsumerStatefulWidget {
  const VoicesContent({super.key});

  @override
  ConsumerState<VoicesContent> createState() => _VoicesContentState();
}

class _VoicesContentState extends ConsumerState<VoicesContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedCategory;
  String? _selectedGender;
  
  @override
  void initState() {
    super.initState();
    
    // Load voices when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sharedVoicesProvider.notifier).loadSharedVoices();
    });
    
    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Handle scrolling to load more voices
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(sharedVoicesProvider.notifier).loadMoreVoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voicesData = ref.watch(sharedVoicesProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Voices',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse and add shared voices to use in your stories.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          
          // Search and filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                // Search input
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search voices...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (value) {
                      ref.read(sharedVoicesProvider.notifier).filterVoices(
                            searchQuery: value.isNotEmpty ? value : null,
                            categoryFilter: _selectedCategory,
                            genderFilter: _selectedGender,
                          );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Category filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      hintText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      ref.read(sharedVoicesProvider.notifier).filterVoices(
                            searchQuery: _searchController.text.isNotEmpty 
                                ? _searchController.text 
                                : null,
                            categoryFilter: value,
                            genderFilter: _selectedGender,
                          );
                    },
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...['professional', 'cloned', 'generated', 'premium'].map(
                        (category) => DropdownMenuItem<String?>(
                          value: category,
                          child: Text(
                            category[0].toUpperCase() + category.substring(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Gender filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                      ref.read(sharedVoicesProvider.notifier).filterVoices(
                            searchQuery: _searchController.text.isNotEmpty 
                                ? _searchController.text 
                                : null,
                            categoryFilter: _selectedCategory,
                            genderFilter: value,
                          );
                    },
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Genders'),
                      ),
                      ...['male', 'female', 'non-binary'].map(
                        (gender) => DropdownMenuItem<String?>(
                          value: gender,
                          child: Text(
                            gender[0].toUpperCase() + gender.substring(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Voice grid
          Expanded(
            child: _buildVoicesList(voicesData),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicesList(SharedVoicesData voicesData) {
    // Show loading state
    if (voicesData.state == SharedVoicesState.loading && voicesData.voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Loading voices...'),
          ],
        ),
      );
    }
    
    // Show error state
    if (voicesData.state == SharedVoicesState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(voicesData.errorMessage ?? 'Failed to load voices'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(sharedVoicesProvider.notifier).refreshVoices();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Show empty state
    if (voicesData.voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.record_voice_over,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No voices found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = null;
                  _selectedGender = null;
                });
                ref.read(sharedVoicesProvider.notifier).filterVoices(
                      searchQuery: null,
                      categoryFilter: null,
                      genderFilter: null,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }
    
    // Show grid of voice cards
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: RefreshIndicator(
        onRefresh: () => ref.read(sharedVoicesProvider.notifier).refreshVoices(),
        color: AppColors.primary,
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 cards per row
            childAspectRatio: 1.2, // Card width:height ratio
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: voicesData.voices.length + (voicesData.hasMoreVoices ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the end if more voices are available
            if (index == voicesData.voices.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final voice = voicesData.voices[index];
            final isPlaying = voicesData.currentlyPlayingVoiceId == voice.id;
            
            return VoiceCard(
              voice: voice,
              isPlaying: isPlaying,
            );
          },
        ),
      ),
    );
  }
}