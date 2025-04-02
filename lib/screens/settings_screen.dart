import 'package:flutter/material.dart';
import '../services/gemini_api_service.dart';
import '../services/elevenlabs_api_service.dart';
import '../utils/secure_storage.dart';
import '../utils/ui/app_colors.dart';
import '../components/settings/index.dart';
import '../components/settings/voices/voices_content.dart';

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
  bool _isGeminiKeyConfigured = false;
  
  // ElevenLabs settings
  String _elevenlabsApiKey = '';
  bool _isElevenlabsApiKeyValid = false;
  bool _isValidatingElevenlabsKey = false;
  String? _elevenlabsErrorText;
  Map<String, dynamic>? _elevenlabsUserInfo;
  bool _isLoadingElevenlabsInfo = false;
  bool _isElevenlabsKeyConfigured = false;
  
  // Settings navigation
  int _selectedSettingIndex = 0;
  
  // Settings change tracking
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }
  
  // Load saved settings from storage
  Future<void> _loadSavedSettings() async {
    setState(() {
      _isGeminiKeyConfigured = false;
      _isElevenlabsKeyConfigured = false;
    });

    // Check if keys are configured
    _isGeminiKeyConfigured = await SecureStorageManager.isGeminiKeyConfigured();
    _isElevenlabsKeyConfigured = await SecureStorageManager.isElevenlabsKeyConfigured();
    
    // Load API keys from secure storage
    final geminiApiKey = await SecureStorageManager.getGeminiApiKey();
    final elevenlabsApiKey = await SecureStorageManager.getElevenlabsApiKey();
    
    // Set Gemini API key if available
    if (geminiApiKey?.isNotEmpty == true) {
      setState(() {
        _geminiApiKey = geminiApiKey ?? '';
        _isGeminiApiKeyValid = true;
      });
    }
    
    // Set ElevenLabs API key if available
    if (elevenlabsApiKey?.isNotEmpty == true) {
      setState(() {
        _elevenlabsApiKey = elevenlabsApiKey ?? '';
        _isElevenlabsApiKeyValid = true;
      });
      
      // Load user info if API key is available
      if (_isElevenlabsKeyConfigured) {
        _loadElevenlabsUserInfo();
      }
    }
    
    setState(() {});
  }
  
  // Validate Gemini API key
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
      _hasChanges = true;
    });
    
    if (isValid) {
      await SecureStorageManager.saveGeminiApiKey(_geminiApiKey);
      setState(() {
        _isGeminiKeyConfigured = true;
      });
    }
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
      _hasChanges = true;
    });
    
    if (isValid) {
      await SecureStorageManager.saveElevenlabsApiKey(_elevenlabsApiKey);
      setState(() {
        _isElevenlabsKeyConfigured = true;
      });
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

  // Save settings and exit
  Future<void> _saveSettings() async {
    if (_geminiApiKey.isNotEmpty && !_isGeminiApiKeyValid) {
      await _validateGeminiApiKey();
    }
    
    if (_elevenlabsApiKey.isNotEmpty && !_isElevenlabsApiKeyValid) {
      await _validateElevenlabsApiKey();
    }
    
    // Show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    setState(() {
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: Show help dialog
            },
            tooltip: 'Help',
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppColors.sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.bgSurface,
        child: Row(
          children: [
            // Sidebar navigation
            SettingsSidebar(
              selectedIndex: _selectedSettingIndex,
              onIndexChanged: (index) {
                setState(() {
                  _selectedSettingIndex = index;
                });
              },
              onSavePressed: _saveSettings,
              hasChanges: _hasChanges,
            ),
            
            // Main content area
            Expanded(
              child: _buildSettingContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build settings content based on selected index
  Widget _buildSettingContent() {
    switch (_selectedSettingIndex) {
      case 0:
        return const VoicesContent();
      case 1:
        return ApiConfigContent(
          // Gemini API properties
          geminiApiKey: _geminiApiKey,
          isGeminiApiKeyValid: _isGeminiApiKeyValid,
          isValidatingGeminiKey: _isValidatingGeminiKey,
          geminiErrorText: _geminiErrorText,
          isGeminiKeyConfigured: _isGeminiKeyConfigured,
          onGeminiKeyChanged: (value) {
            setState(() {
              _geminiApiKey = value;
              _isGeminiApiKeyValid = false;
              _hasChanges = true;
              
              // Clear error when typing
              if (_geminiErrorText != null) {
                _geminiErrorText = null;
              }
            });
          },
          onValidateGeminiKey: _validateGeminiApiKey,
          
          // ElevenLabs API properties
          elevenlabsApiKey: _elevenlabsApiKey,
          isElevenlabsApiKeyValid: _isElevenlabsApiKeyValid,
          isValidatingElevenlabsKey: _isValidatingElevenlabsKey,
          elevenlabsErrorText: _elevenlabsErrorText,
          isElevenlabsKeyConfigured: _isElevenlabsKeyConfigured,
          elevenlabsUserInfo: _elevenlabsUserInfo,
          onElevenlabsKeyChanged: (value) {
            setState(() {
              _elevenlabsApiKey = value;
              _isElevenlabsApiKeyValid = false;
              _hasChanges = true;
              
              // Clear error when typing
              if (_elevenlabsErrorText != null) {
                _elevenlabsErrorText = null;
              }
            });
          },
          onValidateElevenlabsApiKey: _validateElevenlabsApiKey,
        );
      case 2:
        return const PlaceholderContent(
          title: 'Voice Settings',
          icon: Icons.record_voice_over,
        );
      case 3:
        return const PlaceholderContent(
          title: 'Appearance Settings',
          icon: Icons.color_lens_outlined,
        );
      case 4:
        return const PlaceholderContent(
          title: 'Keyboard Shortcuts',
          icon: Icons.keyboard,
        );
      case 5:
        return const PlaceholderContent(
          title: 'Storage Management',
          icon: Icons.storage,
        );
      case 6:
        return const AboutContent();
      default:
        return const SizedBox.shrink();
    }
  }
}
