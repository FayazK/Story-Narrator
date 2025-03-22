import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/gemini_api_service.dart';
import '../services/elevenlabs_api_service.dart';
import '../utils/api_storage.dart';
import '../utils/env_config.dart';
import '../utils/ui/app_colors.dart';
import '../utils/ui/api_key_input.dart';
import '../utils/ui/settings_card.dart';
import '../utils/ui/model_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GeminiApiService _geminiApiService = GeminiApiService();
  final ElevenlabsApiService _elevenlabsApiService = ElevenlabsApiService();
  
  // Gemini settings
  String _geminiApiKey = '';
  bool _isGeminiApiKeyValid = false;
  bool _isValidatingGeminiKey = false;
  String? _geminiErrorText;
  List<String> _availableGeminiModels = [];
  String? _selectedGeminiModel;
  bool _isLoadingGeminiModels = false;
  
  // ElevenLabs settings
  String _elevenlabsApiKey = '';
  bool _isElevenlabsApiKeyValid = false;
  bool _isValidatingElevenlabsKey = false;
  String? _elevenlabsErrorText;
  Map<String, dynamic>? _elevenlabsUserInfo;
  bool _isLoadingElevenlabsInfo = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }
  
  // Load saved settings from environment variables or storage
  Future<void> _loadSavedSettings() async {
    // First try to load API keys from environment variables
    String? geminiApiKey = EnvConfig.getGeminiApiKey();
    String? elevenlabsApiKey = EnvConfig.getElevenlabsApiKey();
    
    // If not found in environment, try from storage
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      geminiApiKey = await ApiKeyStorage.getGeminiApiKey();
    }
    
    if (elevenlabsApiKey == null || elevenlabsApiKey.isEmpty) {
      elevenlabsApiKey = await ApiKeyStorage.getElevenlabsApiKey();
    }
    
    // Set Gemini API key if available
    if (geminiApiKey?.isNotEmpty == true) {
      setState(() {
        _geminiApiKey = geminiApiKey ?? '';
      });
      _validateGeminiApiKey();
    }
    
    // Set ElevenLabs API key if available
    if (elevenlabsApiKey?.isNotEmpty == true) {
      setState(() {
        _elevenlabsApiKey = elevenlabsApiKey ?? '';
      });
      _validateElevenlabsApiKey();
    }
    
    // Load selected Gemini model
    final selectedModel = await ApiKeyStorage.getSelectedGeminiModel();
    if (selectedModel != null) {
      setState(() {
        _selectedGeminiModel = selectedModel;
      });
    }
  }
  
  // Validate Gemini API key and load models
  Future<void> _validateGeminiApiKey() async {
    if (_geminiApiKey.isEmpty) {
      setState(() {
        _isGeminiApiKeyValid = false;
        _geminiErrorText = 'API key cannot be empty';
      });
      return;
    }
    
    setState(() {
      _isValidatingGeminiKey = true;
      _geminiErrorText = null;
    });
    
    final isValid = await _geminiApiService.validateApiKey(_geminiApiKey);
    
    setState(() {
      _isGeminiApiKeyValid = isValid;
      _isValidatingGeminiKey = false;
      _geminiErrorText = isValid ? null : 'Invalid API key';
    });
    
    if (isValid) {
      await ApiKeyStorage.saveGeminiApiKey(_geminiApiKey);
      _loadGeminiModels();
    }
  }
  
  // Load available Gemini models
  Future<void> _loadGeminiModels() async {
    if (!_isGeminiApiKeyValid) return;
    
    setState(() {
      _isLoadingGeminiModels = true;
    });
    
    final models = await _geminiApiService.getAvailableModels(_geminiApiKey);
    
    setState(() {
      _availableGeminiModels = models;
      _isLoadingGeminiModels = false;
      
      // Set default model if none selected
      if (_selectedGeminiModel == null && models.isNotEmpty) {
        _selectedGeminiModel = models.contains(_geminiApiService.getDefaultModel())
            ? _geminiApiService.getDefaultModel()
            : models.first;
        
        // Save the selected model
        ApiKeyStorage.saveSelectedGeminiModel(_selectedGeminiModel!);
      }
    });
  }
  
  // Validate ElevenLabs API key and load user info
  Future<void> _validateElevenlabsApiKey() async {
    if (_elevenlabsApiKey.isEmpty) {
      setState(() {
        _isElevenlabsApiKeyValid = false;
        _elevenlabsErrorText = 'API key cannot be empty';
      });
      return;
    }
    
    setState(() {
      _isValidatingElevenlabsKey = true;
      _elevenlabsErrorText = null;
    });
    
    final isValid = await _elevenlabsApiService.validateApiKey(_elevenlabsApiKey);
    
    setState(() {
      _isElevenlabsApiKeyValid = isValid;
      _isValidatingElevenlabsKey = false;
      _elevenlabsErrorText = isValid ? null : 'Invalid API key';
    });
    
    if (isValid) {
      await ApiKeyStorage.saveElevenlabsApiKey(_elevenlabsApiKey);
      _loadElevenlabsUserInfo();
    }
  }
  
  // Load ElevenLabs user info
  Future<void> _loadElevenlabsUserInfo() async {
    if (!_isElevenlabsApiKeyValid) return;
    
    setState(() {
      _isLoadingElevenlabsInfo = true;
    });
    
    final userInfo = await _elevenlabsApiService.getUserInfo(_elevenlabsApiKey);
    
    setState(() {
      _elevenlabsUserInfo = userInfo;
      _isLoadingElevenlabsInfo = false;
    });
  }
  
  // Handle model selection change
  void _onModelSelected(String? model) {
    if (model != null) {
      setState(() {
        _selectedGeminiModel = model;
      });
      
      // Save the selected model
      ApiKeyStorage.saveSelectedGeminiModel(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Gemini API Settings
            SettingsCard(
              title: 'Google Gemini API',
              subtitle: 'Configure your Gemini AI model settings',
              icon: Icons.auto_awesome,
              isExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Key input
                  ApiKeyInput(
                    label: 'Gemini API Key',
                    initialValue: _geminiApiKey,
                    hintText: 'Enter your Gemini API key',
                    errorText: _geminiErrorText,
                    isLoading: _isValidatingGeminiKey,
                    isValid: _isGeminiApiKeyValid,
                    onChanged: (value) {
                      setState(() {
                        _geminiApiKey = value;
                        _isGeminiApiKeyValid = false;
                      });
                    },
                    onValidate: _validateGeminiApiKey,
                  ),
                  const SizedBox(height: 20),
                  
                  // Model selector
                  ModelSelector(
                    selectedModel: _selectedGeminiModel,
                    availableModels: _availableGeminiModels,
                    onChanged: _onModelSelected,
                    isLoading: _isLoadingGeminiModels,
                  ),
                  
                  // Help text about getting an API key
                  const SizedBox(height: 16),
                  Text(
                    'Get your Gemini API key from Google AI Studio at ai.google.dev',
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // ElevenLabs API Settings
            SettingsCard(
              title: 'ElevenLabs API',
              subtitle: 'Configure your text-to-speech settings',
              icon: Icons.record_voice_over,
              isExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Key input
                  ApiKeyInput(
                    label: 'ElevenLabs API Key',
                    initialValue: _elevenlabsApiKey,
                    hintText: 'Enter your ElevenLabs API key',
                    errorText: _elevenlabsErrorText,
                    isLoading: _isValidatingElevenlabsKey,
                    isValid: _isElevenlabsApiKeyValid,
                    onChanged: (value) {
                      setState(() {
                        _elevenlabsApiKey = value;
                        _isElevenlabsApiKeyValid = false;
                      });
                    },
                    onValidate: _validateElevenlabsApiKey,
                  ),
                  
                  // ElevenLabs account info (if available)
                  if (_elevenlabsUserInfo != null) ...[
                    const SizedBox(height: 24),
                    _buildElevenlabsInfoCard(),
                  ],
                  
                  // Help text about getting an API key
                  const SizedBox(height: 16),
                  Text(
                    'Get your ElevenLabs API key from elevenlabs.io/account',
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // Save button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(
              duration: 300.ms,
              delay: 200.ms,
            ).slideY(
              begin: 0.2,
              end: 0,
              curve: Curves.easeOutCubic,
              duration: 400.ms,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build the ElevenLabs account info card
  Widget _buildElevenlabsInfoCard() {
    if (_elevenlabsUserInfo == null) return const SizedBox.shrink();
    
    final subscription = _elevenlabsUserInfo!['subscription'] as Map<String, dynamic>?;
    final characterCount = _elevenlabsUserInfo!['subscription']['character_count'] ?? 0;
    final characterLimit = _elevenlabsUserInfo!['subscription']['character_limit'] ?? 0;
    
    final usagePercentage = characterLimit > 0 
        ? (characterCount / characterLimit * 100).clamp(0, 100)
        : 0.0;
    
    final tier = subscription?['tier'] ?? 'Free';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        border: Border.all(
          color: Colors.purple.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Subscription tier
          Row(
            children: [
              Icon(
                Icons.card_membership,
                color: AppColors.textMedium,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Tier: ',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
              Text(
                tier,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Character usage
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: AppColors.textMedium,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Characters: ',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
              Text(
                '$characterCount / $characterLimit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Usage progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercentage > 90 
                    ? Colors.red 
                    : usagePercentage > 70 
                        ? Colors.orange 
                        : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${usagePercentage.toStringAsFixed(1)}% used',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 500.ms,
      delay: 200.ms,
    ).moveY(
      begin: 10,
      end: 0,
      curve: Curves.easeOutCubic,
      duration: 400.ms,
    );
  }
}
