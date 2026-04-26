import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';

/// Wallet address input field + LOAD button.
/// [onLoad] is called with the raw text when the button is tapped or
/// the keyboard action is submitted. [isLoading] shows a compact spinner
/// inside the button. [errorText] renders an inline error below the field.
class AddressInputRow extends StatefulWidget {
  const AddressInputRow({
    super.key,
    required this.onLoad,
    this.isLoading = false,
    this.errorText,
    this.initialAddress,
    this.onClear,
  });

  final void Function(String address) onLoad;
  final bool isLoading;
  final String? errorText;
  final String? initialAddress;
  final VoidCallback? onClear;

  @override
  State<AddressInputRow> createState() => _AddressInputRowState();
}

class _AddressInputRowState extends State<AddressInputRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialAddress ?? '');
  }

  @override
  void didUpdateWidget(AddressInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAddress != oldWidget.initialAddress &&
        widget.initialAddress != null &&
        _ctrl.text != widget.initialAddress) {
      _ctrl.text = widget.initialAddress!;
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() => widget.onLoad(_ctrl.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _AddressField(
                  controller: _ctrl,
                  onSubmitted: (_) => _submit(),
                  hasError: widget.errorText != null,
                  enabled: !widget.isLoading,
                ),
              ),
              const SizedBox(width: 8),
              _LoadButton(
                onTap: _submit,
                isLoading: widget.isLoading,
              ),
              if (widget.onClear != null) ...[
                const SizedBox(width: 4),
                _ClearButton(onTap: widget.onClear!),
              ],
            ],
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.errorText!,
              style: AppTextStyles.rowSecondary
                  .copyWith(color: AppColors.negative),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.onSubmitted,
    required this.hasError,
    required this.enabled,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: AppTextStyles.rowPrimary.copyWith(
        fontFamily: 'monospace',
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '0x...',
        hintStyle:
            AppTextStyles.rowSecondary.copyWith(color: AppColors.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.bgSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.negative : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.negative : AppColors.accent,
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      onSubmitted: onSubmitted,
    );
  }
}

class _LoadButton extends StatelessWidget {
  const _LoadButton({required this.onTap, required this.isLoading});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.bgDeep,
                ),
              )
            : Text(
                'LOAD',
                style: AppTextStyles.chipText.copyWith(color: AppColors.bgDeep),
              ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
      ),
    );
  }
}
