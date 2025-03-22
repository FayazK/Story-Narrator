import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ui/app_colors.dart';
import '../../utils/ui/api_key_input.dart';
import 'settings_section_card.dart';

class ApiConfigContent extends StatelessWidget {
  // Gemini API properties
  final String geminiApiKey;
  final bool isGeminiApiKeyValid;
  final bool isValidatingGeminiKey;
  final String? geminiErrorText;
  final bool isGeminiKeyConfigured;
  final ValueChanged<String> onGeminiKeyChanged;
  final VoidCallback onValidateGeminiKey;
  
  // ElevenLabs API properties
  final String elevenlabsApiKey;
  final bool isElevenlabsApiKeyValid;
  final bool isValidatingElevenlabsKey;
  final String? elevenlabsErrorText;
  final bool isElevenlabsKeyConfigured;
  final Map<String, dynamic>? elevenlabsUserInfo;
  final ValueChanged<String> onElevenlabsKeyChanged;
  final VoidCallback onValidateElevenlabsKey;

  const ApiConfigContent({
    super.key,
    // Gemini API properties
    required this.geminiApiKey,
    required this.isGeminiApiKeyValid,
    required this.isValidatingGeminiKey,
    required this.geminiErrorText,
    required this.isGeminiKeyConfigured,
    required this.onGeminiKeyChanged,
    required this.onValidateGeminiKey,
    
    // ElevenLabs API properties
    required this.elevenlabsApiKey,
    required this.isElevenlabsApiKeyValid,
    required this.isValidatingElevenlabsKey,
    required this.elevenlabsErrorText,
    required this.isElevenlabsKeyConfigured,
    required this.elevenlabsUserInfo,
    required this.onElevenlabsKeyChanged,
    required this.onValidateElevenlabsKey,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'API Configuration',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your API keys for AI generation and text-to-speech services.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 32),
          
          // Gemini API Settings
          SettingsSectionCard(
            title: 'Google Gemini API',
            description: 'Power your story generation with Google\'s Gemini AI model.',
            icon: Icons.auto_awesome,
            iconColor: Colors.blue,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                if (isGeminiKeyConfigured) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'API key configured and valid',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // API Key input
                ApiKeyInput(
                  label: 'Gemini API Key',
                  initialValue: geminiApiKey,
                  hintText: 'Enter your Gemini API key',
                  errorText: geminiErrorText,
                  isLoading: isValidatingGeminiKey,
                  isValid: isGeminiApiKeyValid,
                  onChanged: onGeminiKeyChanged,
                  onValidate: onValidateGeminiKey,
                ),
                
                // Help text
                const SizedBox(height: 20),
                Text(
                  'Get your Gemini API key from Google AI Studio at ai.google.dev',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14,
                  ),
                ),
                
                // Model selection (future feature)
                const SizedBox(height: 32),
                Text(
                  'AI Model Selection',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Disabled model selector (future feature)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Gemini 1.5 Pro (default)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Coming soon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // ElevenLabs API Settings
          SettingsSectionCard(
            title: 'ElevenLabs API',
            description: 'Enable text-to-speech features with ElevenLabs voice technology.',
            icon: Icons.record_voice_over,
            iconColor: Colors.orange,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                if (isElevenlabsKeyConfigured) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'API key configured and valid',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // API Key input
                ApiKeyInput(
                  label: 'ElevenLabs API Key',
                  initialValue: elevenlabsApiKey,
                  hintText: 'Enter your ElevenLabs API key',
                  errorText: elevenlabsErrorText,
                  isLoading: isValidatingElevenlabsKey,
                  isValid: isElevenlabsApiKeyValid,
                  onChanged: onElevenlabsKeyChanged,
                  onValidate: onValidateElevenlabsKey,
                ),
                
                // Help text
                const SizedBox(height: 20),
                Text(
                  'Get your ElevenLabs API key from elevenlabs.io/account',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14,
                  ),
                ),
                
                // ElevenLabs account info (if available)
                if (elevenlabsUserInfo != null) ...[
                  const SizedBox(height: 32),
                  _buildElevenlabsInfoCard(elevenlabsUserInfo!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the ElevenLabs account info card
  Widget _buildElevenlabsInfoCard(Map<String, dynamic> userInfo) {
    final subscription = userInfo['subscription'] as Map<String, dynamic>?;
    final characterCount = userInfo['subscription']['character_count'] ?? 0;
    final characterLimit = userInfo['subscription']['character_limit'] ?? 0;
    
    final usagePercentage = characterLimit > 0 
        ? (characterCount / characterLimit * 100).clamp(0, 100)
        : 0.0;
    
    final tier = subscription?['tier'] ?? 'Free';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        border: Border.all(
          color: Colors.grey.shade200,
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
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Account Information',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Subscription tier
          Row(
            children: [
              Icon(
                Icons.card_membership,
                color: AppColors.textMedium,
                size: 16,
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
          
          // Character usage
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: AppColors.textMedium,
                size: 16,
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          
          // Usage progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage: ${usagePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
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
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: 200.ms,
    ).moveY(
      begin: 10,
      end: 0,
      curve: Curves.easeOutCubic,
      duration: 400.ms,
    );
  }
}
