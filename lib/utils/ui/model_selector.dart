import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A dropdown selector for model selection with a modern UI
class ModelSelector extends StatelessWidget {
  final String? selectedModel;
  final List<String> availableModels;
  final Function(String?) onChanged;
  final bool isLoading;
  
  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.availableModels,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format model name for display (e.g., "models/gemini-1.5-pro" -> "Gemini 1.5 Pro")
    String formatModelName(String modelName) {
      // Remove "models/" prefix if it exists
      String formattedName = modelName.replaceAll('models/', '');
      
      // Split by dashes
      List<String> parts = formattedName.split('-');
      
      // Capitalize the first letter of each part
      parts = parts.map((part) {
        if (part.isEmpty) return part;
        return part[0].toUpperCase() + part.substring(1);
      }).toList();
      
      // Join parts with spaces
      return parts.join(' ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Model',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: selectedModel,
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLight,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: availableModels.map((model) {
                    return DropdownMenuItem<String>(
                      value: model,
                      child: Text(formatModelName(model)),
                    );
                  }).toList(),
                  onChanged: (isLoading || availableModels.isEmpty) ? null : onChanged,
                  hint: availableModels.isEmpty
                      ? const Text('No models available')
                      : const Text('Select a model'),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          availableModels.isEmpty
              ? 'Enter a valid API key to load available models.'
              : 'Select the model you want to use for generating stories.',
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
