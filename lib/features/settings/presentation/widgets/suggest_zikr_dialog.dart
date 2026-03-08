import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/zikr_suggestion_service.dart';
import 'package:flutter/material.dart';

class SuggestZikrDialog extends StatefulWidget {
  const SuggestZikrDialog({super.key});

  @override
  State<SuggestZikrDialog> createState() => _SuggestZikrDialogState();
}

class _SuggestZikrDialogState extends State<SuggestZikrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isWithCounter = false;
  ZikrLevel _zikrLevel = ZikrLevel.easy;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ZikrSuggestionService.submitSuggestion(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        source: _sourceController.text.trim(),
        isWithCounter: _isWithCounter,
        zikrLevel: _zikrLevel == ZikrLevel.easy ? 'easy' : 'hard',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('suggest_zikr_success'.tr()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('suggest_zikr_error'.tr()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'suggest_zikr_title'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'suggest_zikr_subtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'suggest_field_title'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'suggest_field_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'suggest_field_description'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'suggest_field_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Source field
                TextFormField(
                  controller: _sourceController,
                  decoration: InputDecoration(
                    labelText: 'suggest_field_source'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.source),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'suggest_field_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Is with counter switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('suggest_field_counter'.tr()),
                  subtitle: Text(
                    'suggest_field_counter_desc'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  value: _isWithCounter,
                  onChanged: (val) => setState(() => _isWithCounter = val),
                ),
                const SizedBox(height: 8),

                // Zikr level dropdown
                DropdownButtonFormField<ZikrLevel>(
                  value: _zikrLevel,
                  decoration: InputDecoration(
                    labelText: 'suggest_field_level'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.speed),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ZikrLevel.easy,
                      child: Text('easy'.tr()),
                    ),
                    DropdownMenuItem(
                      value: ZikrLevel.hard,
                      child: Text('hard'.tr()),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _zikrLevel = val);
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting
                        ? 'suggest_submitting'.tr()
                        : 'suggest_submit'.tr(),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
