import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  void _openAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Materiales';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Registrar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción del gasto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto (\$)'),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Materiales', child: Text('Materiales y Libros')),
                  DropdownMenuItem(value: 'Software', child: Text('Software y Licencias')),
                  DropdownMenuItem(value: 'Insumos', child: Text('Insumos de Aula')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Varios', child: Text('Varios')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => category = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (descController.text.trim().isNotEmpty && amount > 0) {
                  ref.read(expensesProvider.notifier).addExpense(
                    description: descController.text.trim(),
                    amount: amount,
                    category: category,
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financeSummaryProvider);
    final period = ref.watch(selectedPeriodProvider);
    final expenses = ref.watch(expensesProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Estadísticas Financieras', style: AppTextStyles.titleMedium),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro de periodo
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Mes Actual'),
                    selected: period == FinancePeriod.currentMonth,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: period == FinancePeriod.currentMonth ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    onSelected: (val) => ref.read(selectedPeriodProvider.notifier).state = FinancePeriod.currentMonth,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilterChip(
                    label: const Text('Mes Anterior'),
                    selected: period == FinancePeriod.previousMonth,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: period == FinancePeriod.previousMonth ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    onSelected: (val) => ref.read(selectedPeriodProvider.notifier).state = FinancePeriod.previousMonth,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilterChip(
                    label: const Text('Todo el Año'),
                    selected: period == FinancePeriod.allTime,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: period == FinancePeriod.allTime ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    onSelected: (val) => ref.read(selectedPeriodProvider.notifier).state = FinancePeriod.allTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tarjetas de Métricas (Ingresos, Gastos, Ganancia)
            Row(
              children: [
                Expanded(
                  child: _buildFinancialTile(
                    title: 'Ingresos',
                    amount: summary.totalIncome,
                    color: AppColors.secondary,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFinancialTile(
                    title: 'Gastos',
                    amount: summary.totalExpenses,
                    color: AppColors.error,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ganancia Neta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ganancia Neta (Ingresos - Gastos)', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(summary.netProfit),
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: summary.netProfit >= 0 ? primaryColor : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Margen: ${summary.profitMargin}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gráfico dinámico de distribución
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distribución Financiera', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: [
                          Expanded(
                            flex: summary.totalIncome > 0 ? summary.totalIncome.round() : 1,
                            child: Container(color: AppColors.secondary),
                          ),
                          Expanded(
                            flex: summary.totalExpenses > 0 ? summary.totalExpenses.round() : 0,
                            child: Container(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Cobrado: ${formatCurrency(summary.totalIncome)}', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Gastos: ${formatCurrency(summary.totalExpenses)}', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Encabezado de Gastos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gastos del Docente', style: AppTextStyles.titleMedium),
                ElevatedButton.icon(
                  onPressed: () => _openAddExpenseDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Registrar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Lista de Gastos o estado vacío
            if (expenses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Text(
                  'No hay gastos registrados en este periodo.',
                  style: AppTextStyles.bodyMedium,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final exp = expenses[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp.description, style: AppTextStyles.titleSmall),
                            Text('${exp.category} • ${exp.date}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                        Text(
                          '-${formatCurrency(exp.amount)}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTile({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelMedium),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(amount),
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
