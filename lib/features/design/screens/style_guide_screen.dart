import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';

/// Catálogo vivo de los componentes de Docentia.
/// Si un componente ya está aquí, las pantallas nuevas deben reutilizarlo.
class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  final _sampleController = TextEditingController();

  @override
  void dispose() {
    _sampleController.dispose();
    super.dispose();
  }

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
          'Estilos',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _section(
            title: 'Etiqueta de campo',
            note: '12 px, seminegrita y el mismo gris en todos los campos.',
            child: const AppFieldLabel('Nombre del curso'),
          ),
          const SizedBox(height: 22),
          _section(
            title: 'Campo de texto',
            note: 'Fondo suave, borde redondeado y la etiqueta de arriba.',
            child: AppTextField(
              label: 'Nombre',
              controller: _sampleController,
              hint: 'Ej. Ana',
            ),
          ),
          const SizedBox(height: 22),
          _section(
            title: 'Botón primario',
            note: 'Relleno con el color primario seleccionado y texto blanco.',
            child: AppPrimaryButton(
              label: 'Registrar',
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Los textos de ejemplo usan el mismo tamaño y color que el resto de la app.',
            style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String note,
    required Widget child,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          note,
          style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
