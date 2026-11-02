import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../courses/providers/courses_provider.dart';
import '../../students/providers/students_provider.dart';
import '../models/subscription_config.dart';
import '../providers/subscription_provider.dart';
import '../widgets/paywall_sheet.dart';

/// Muestra el paywall si hace falta. Devuelve `true` si el usuario ya tiene acceso Pro.
Future<bool> ensureProFeature(
  BuildContext context,
  WidgetRef ref, {
  required ProFeature feature,
}) async {
  final status = ref.read(subscriptionProvider);
  if (status.canAccess(feature)) return true;
  await showPaywallSheet(context, feature: feature);
  return ref.read(subscriptionProvider).canAccess(feature);
}

/// Para pantallas Pro alcanzables por ruta: pide upgrade y regresa si no hay acceso.
void guardProRoute(
  BuildContext context,
  WidgetRef ref, {
  required ProFeature feature,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) return;
    if (ref.read(subscriptionProvider).canAccess(feature)) return;
    final ok = await ensureProFeature(context, ref, feature: feature);
    if (!context.mounted) return;
    if (ok) return;
    if (context.canPop()) {
      context.pop();
    } else if (context.mounted) {
      context.go('/home');
    }
  });
}

/// Valida límite de cursos Free antes de abrir el diálogo de creación.
Future<bool> ensureCanCreateCourse(BuildContext context, WidgetRef ref) async {
  final status = ref.read(subscriptionProvider);
  if (status.isPro) return true;

  final courses = ref.read(coursesProvider).value ?? const [];
  final activeCount = courses.where((c) => c.active).length;
  if (status.canCreateCourse(activeCount)) return true;

  await showPaywallSheet(context, feature: ProFeature.courseLimit);
  return ref.read(subscriptionProvider).isPro;
}

/// Valida límite de alumnos Free antes de abrir el alta.
Future<bool> ensureCanAddStudent(BuildContext context, WidgetRef ref) async {
  final status = ref.read(subscriptionProvider);
  if (status.isPro) return true;

  final students = await ref.read(allActiveStudentsProvider.future);
  if (status.canAddStudent(students.length)) return true;

  await showPaywallSheet(context, feature: ProFeature.studentLimit);
  return ref.read(subscriptionProvider).isPro;
}
