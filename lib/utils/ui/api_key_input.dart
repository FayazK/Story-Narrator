import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_colors.dart';

/// A custom text field for API key input with validation and visibility toggle
class ApiKeyInput extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final String? errorText;
  final bool isLoading;
  final bool isValid;
  final Function(String) onChanged;
  final VoidCallback? onValidate;
  
  const ApiKeyInput({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.isLoading = false,
    this.isValid = false,
    required this.onChanged,
    this.onValidate,
  });

  @override
  State<ApiKeyInput> createState() => _ApiKeyInputState();
}

class _ApiKeyInputState extends State<ApiKeyInput> {
  bool _obscureText = true;
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ApiKeyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        // Input field with validation
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Enter your API key',
              errorText: widget.errorText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isValid ? Colors.green : AppColors.primaryLight,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isValid ? Colors.green : AppColors.primaryLight,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isValid 
                      ? Colors.green 
                      : AppColors.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle visibility button
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  
                  // Validation status indicator
                  if (widget.isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else if (widget.isValid)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ).animate().scale(
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    )
                  else if (widget.errorText != null)
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                    )
                  else if (widget.onValidate != null && _controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.grey,
                      ),
                      onPressed: widget.onValidate,
                      tooltip: 'Validate API Key',
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
