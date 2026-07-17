import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key});

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  bool _isSaving = false;
  TimeOfDay? _time;

  HabitCategory _category = HabitCategory.physical;
  HabitUnit _unit = HabitUnit.minutes;

  // ── Opciones de categoría ─────────────────────────────────────────────────
  static const _categories = [
    (
      value: HabitCategory.cognitive,
      label: 'Cognitivo',
      icon: Icons.menu_book_rounded,
    ),
    (
      value: HabitCategory.physical,
      label: 'Físico',
      icon: Icons.fitness_center_rounded,
    ),
    (
      value: HabitCategory.hydration,
      label: 'Hidratación',
      icon: Icons.water_drop_rounded,
    ),
    (
      value: HabitCategory.productivity,
      label: 'Productividad',
      icon: Icons.school_rounded,
    ),
    (value: HabitCategory.rest, label: 'Descanso', icon: Icons.bedtime_rounded),
  ];

  // ── Opciones de unidad ────────────────────────────────────────────────────
  static const _units = [
    (value: HabitUnit.minutes, label: 'Minutos'),
    (value: HabitUnit.km, label: 'Kilómetros'),
    (value: HabitUnit.liters, label: 'Litros'),
    (value: HabitUnit.steps, label: 'Pasos'),
    (value: HabitUnit.times, label: 'Veces'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final goalStr = _goalCtrl.text.trim();

    if (name.isEmpty) {
      _showError('El nombre no puede estar vacío');
      return;
    }
    final goalValue = double.tryParse(goalStr);
    if (goalValue == null || goalValue <= 0) {
      _showError('Ingresa una meta válida (mayor a 0)');
      return;
    }

    // Construir DateTime de hoy con la hora seleccionada
    DateTime? scheduledTime;
    if (_time != null) {
      final now = DateTime.now();
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _time!.hour,
        _time!.minute,
      );
    }

    setState(() => _isSaving = true);

    await ref
        .read(habitsProvider.notifier)
        .createHabit(
          name: name,
          category: _category,
          goalValue: goalValue,
          unit: _unit,
          scheduledTime: scheduledTime,
        );

    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.pending,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 20,
        right: 20,
        top: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Título del sheet
          const Text(
            'Nuevo hábito',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // ── Nombre ──────────────────────────────────────────────────
          _Label('Nombre del hábito'),
          const SizedBox(height: 6),
          _Field(
            controller: _nameCtrl,
            hint: 'Ej. Leer, Yoga, Tomar agua...',
            icon: Icons.edit_rounded,
          ),
          const SizedBox(height: 16),

          // ── Categoría ────────────────────────────────────────────────
          _Label('Categoría'),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((cat) {
                final selected = _category == cat.value;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.divider,
                        width: selected ? 0 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.icon,
                          color: selected ? Colors.white : AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Meta + Unidad ─────────────────────────────────────────────
          Row(
            children: [
              // Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Meta'),
                    const SizedBox(height: 6),
                    _Field(
                      controller: _goalCtrl,
                      hint: 'Ej. 30',
                      icon: Icons.flag_rounded,
                      keyboard: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Unidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Unidad'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HabitUnit>(
                          value: _unit,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                          items: _units
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u.value,
                                  child: Text(u.label),
                                ),
                              )
                              .toList(),
                          onChanged: (u) {
                            if (u != null) setState(() => _unit = u);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Hora (opcional) ───────────────────────────────────────────
          _Label('Hora programada (opcional)'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _time != null ? AppTheme.primary : AppTheme.divider,
                  width: _time != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: _time != null
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _time == null
                        ? 'Toca para seleccionar hora'
                        : _formatTime(_time!),
                    style: TextStyle(
                      fontSize: 13,
                      color: _time == null
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                      fontWeight: _time != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (_time != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _time = null),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Botones ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.divider),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar hábito',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    );
  }
}
