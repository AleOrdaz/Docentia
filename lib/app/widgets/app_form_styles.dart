import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Fondo de las pantallas principales.
Color appPageBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE);
}

/// Etiqueta de campo: 12 px, seminegrita, gris según el tema.
TextStyle appInputLabelStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppTextStyles.labelSmall.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF43474E),
  );
}

class AppFieldLabel extends StatelessWidget {
  final String text;

  const AppFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: appInputLabelStyle(context));
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.outlineAdaptive(context),
            ),
            filled: true,
            fillColor: AppColors.surfaceLow(context),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.outlineVariantAdaptive(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.outlineVariantAdaptive(context)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Acción principal: botón relleno con el color primario del tema.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w600));

    final style = FilledButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: const StadiumBorder(),
    );

    if (icon == null || loading) {
      return FilledButton(onPressed: loading ? null : onPressed, style: style, child: child);
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: child,
    );
  }
}

/// Formulario en página completa. Los altas y ediciones largas usan esta
/// estructura en lugar de un modal.
class AppFormPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;

  const AppFormPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Scaffold(
      backgroundColor: appPageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                  ],
                  body,
                ],
              ),
            ),
          ),
          if (footer != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }
}
