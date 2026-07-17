import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

class AddProgressDialog extends ConsumerStatefulWidget {
  final Habit habit;
  const AddProgressDialog({super.key, required this.habit});

  @override
  ConsumerState<AddProgressDialog> createState() => _AddProgressDialogState();
}

class _AddProgressDialogState extends ConsumerState<AddProgressDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final val = double.tryParse(_ctrl.text.trim());
    if (val != null && val > 0) {
      final newValue = widget.habit.currentValue + val;
      ref
          .read(habitsProvider.notifier)
          .updateProgress(widget.habit.id, newValue);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir progreso'),
      content: TextField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: 'Ej. 5',
          suffixText: widget.habit.unit.name,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primary, width: 2),
          ),
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
