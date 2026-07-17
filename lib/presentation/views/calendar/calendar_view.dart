import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/domain/entities/reminder.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  static const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // weekday: 1=lunes … 7=domingo → necesitamos offset 0-based
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    final cells = <DateTime?>[];
    for (int i = 0; i < offset; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    // Completar última fila
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  bool _isSelected(DateTime day) {
    if (_selectedDay == null) return false;
    return day.year == _selectedDay!.year &&
        day.month == _selectedDay!.month &&
        day.day == _selectedDay!.day;
  }

  String _monthLabel() {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _onDayTap(DateTime day) {
    setState(() => _selectedDay = day);
    _showDayBottomSheet(day);
  }

  // ── Bottom sheet principal del día ───────────────────────────────────────

  void _showDayBottomSheet(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayBottomSheet(day: day),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reminderList = ref
        .watch(remindersProvider)
        .maybeWhen(data: (list) => list, orElse: () => <Reminder>[]);
    final notifier = ref.read(remindersProvider.notifier);
    final markedDays = notifier.daysWithReminders(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final calendarDays = _buildCalendarDays();

    return Column(
      children: [
        // ── Encabezado del mes ──────────────────────────────────────────
        _MonthHeader(
          label: _monthLabel(),
          onPrev: _previousMonth,
          onNext: _nextMonth,
        ),

        const SizedBox(height: 8),

        // ── Días de la semana ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _weekDays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: 6),

        // ── Grilla del mes ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              if (day == null) return const SizedBox.shrink();

              final isToday = _isToday(day);
              final isSelected = _isSelected(day);
              final hasReminder = markedDays.contains(day.day);

              return _DayCell(
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                hasReminder: hasReminder,
                onTap: () => _onDayTap(day),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
        const Divider(color: AppTheme.divider, height: 1),
        const SizedBox(height: 12),

        // ── Leyenda ─────────────────────────────────────────────────────
        _Legend(),

        const SizedBox(height: 12),

        // ── Próximos recordatorios ──────────────────────────────────────
        Expanded(
          child: _UpcomingReminders(
            reminders: reminderList,
            onDelete: (id) =>
                ref.read(remindersProvider.notifier).removeReminder(id),
          ),
        ),
      ],
    );
  }
}

// ── Encabezado del mes ───────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppTheme.primary,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ── Celda de día ─────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool hasReminder;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasReminder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;
    Border? border;

    if (isSelected && isToday) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = AppTheme.primary.withValues(alpha: 0.15);
      textColor = AppTheme.primary;
      border = Border.all(color: AppTheme.primary, width: 1.5);
    } else if (isToday) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: textColor,
              ),
            ),
            // Dot indicador de recordatorio
            if (hasReminder) ...[
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || isToday ? Colors.white : AppTheme.streak,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Leyenda ──────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _LegendItem(color: AppTheme.primary, label: 'Hoy'),
          const SizedBox(width: 16),
          _LegendItem(
            color: AppTheme.primary.withValues(alpha: 0.15),
            label: 'Día seleccionado',
            borderColor: AppTheme.primary,
          ),
          const SizedBox(width: 16),
          _LegendItem(
            color: AppTheme.streak,
            label: 'Con recordatorio',
            isCircle: true,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? borderColor;
  final bool isCircle;

  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isCircle ? 8 : 14,
          height: isCircle ? 8 : 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

// ── Lista de próximos recordatorios ──────────────────────────────────────────

class _UpcomingReminders extends StatelessWidget {
  final List<Reminder> reminders;
  final void Function(String id) onDelete;

  const _UpcomingReminders({required this.reminders, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming =
        reminders
            .where((r) => r.date.isAfter(now.subtract(const Duration(days: 1))))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximos recordatorios',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${upcoming.length} pendiente${upcoming.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (upcoming.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: AppTheme.divider,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sin recordatorios próximos',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: upcoming.length,
              itemBuilder: (context, i) => _ReminderTile(
                reminder: upcoming[i],
                onDelete: () => onDelete(upcoming[i].id),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const _ReminderTile({required this.reminder, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        reminder.date.year == now.year &&
        reminder.date.month == now.month &&
        reminder.date.day == now.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de categoría
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _categoryColor(reminder.category).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(reminder.category),
              color: _categoryColor(reminder.category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: isToday
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isToday
                          ? 'Hoy • ${reminder.timeLabel}'
                          : '${_dateLabel(reminder.date)} • ${reminder.timeLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (reminder.description != null &&
                    reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reminder.description!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Chip de categoría + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _categoryColor(
                    reminder.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  reminder.categoryLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: _categoryColor(reminder.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  IconData _categoryIcon(ReminderCategory cat) {
    return switch (cat) {
      ReminderCategory.habit => Icons.repeat_rounded,
      ReminderCategory.exercise => Icons.fitness_center_rounded,
      ReminderCategory.hydration => Icons.water_drop_rounded,
      ReminderCategory.rest => Icons.bedtime_rounded,
      ReminderCategory.productivity => Icons.school_rounded,
      ReminderCategory.other => Icons.event_note_rounded,
    };
  }

  Color _categoryColor(ReminderCategory cat) {
    return switch (cat) {
      ReminderCategory.habit => AppTheme.primary,
      ReminderCategory.exercise => AppTheme.completed,
      ReminderCategory.hydration => const Color(0xFF0984E3),
      ReminderCategory.rest => const Color(0xFF6C5CE7),
      ReminderCategory.productivity => AppTheme.pending,
      ReminderCategory.other => AppTheme.textSecondary,
    };
  }
}

// ── Bottom Sheet del día seleccionado ────────────────────────────────────────

class _DayBottomSheet extends ConsumerStatefulWidget {
  final DateTime day;
  const _DayBottomSheet({required this.day});

  @override
  ConsumerState<_DayBottomSheet> createState() => _DayBottomSheetState();
}

class _DayBottomSheetState extends ConsumerState<_DayBottomSheet> {
  bool _showForm = false;
  Reminder? _editingReminder;

  @override
  Widget build(BuildContext context) {
    ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);
    final reminders = notifier.forDay(widget.day);
    final isToday = _isToday(widget.day);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabecera del día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.day.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Hoy' : _fullDateLabel(widget.day),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${reminders.length} recordatorio${reminders.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Botón agregar
                if (!_showForm)
                  FilledButton.icon(
                    onPressed: () => setState(() => _showForm = true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Agregar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(color: AppTheme.divider, height: 1),

          // Formulario de nuevo recordatorio
          if (_showForm)
            _ReminderForm(
              day: widget.day,
              editing: _editingReminder, // ← AGREGAR
              onSave: (r) async {
                final notifier = ref.read(remindersProvider.notifier);
                if (_editingReminder != null) {
                  // Editar: borrar el viejo e insertar el nuevo
                  await notifier.removeReminder(_editingReminder!.id);
                }
                await notifier.addReminder(r);
                setState(() {
                  _showForm = false;
                  _editingReminder = null;
                });
              },
              onCancel: () => setState(() {
                _showForm = false;
                _editingReminder = null;
              }),
            ),

          // Lista de recordatorios del día
          if (reminders.isEmpty && !_showForm)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 40,
                    color: AppTheme.divider,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sin recordatorios para este día',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => setState(() => _showForm = true),
                    child: const Text('+ Agregar uno'),
                  ),
                ],
              ),
            )
          else if (!_showForm)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: reminders.length,
                itemBuilder: (context, i) => _SheetReminderTile(
                  reminder: reminders[i],
                  onDelete: () {
                    ref
                        .read(remindersProvider.notifier)
                        .removeReminder(reminders[i].id);
                  },
                  onEdit: () {
                    setState(() {
                      _showForm = true;
                      _editingReminder = reminders[i]; // ← ver abajo
                    });
                  },
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  String _fullDateLabel(DateTime d) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${days[d.weekday - 1]} ${d.day} de ${months[d.month - 1]}';
  }
}

// ── Tile dentro del bottom sheet ─────────────────────────────────────────────

class _SheetReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _SheetReminderTile({
    required this.reminder,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(
            _categoryIcon(reminder.category),
            size: 20,
            color: _categoryColor(reminder.category),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (reminder.time != null)
                  Text(
                    reminder.timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _categoryColor(reminder.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              reminder.categoryLabel,
              style: TextStyle(
                fontSize: 10,
                color: _categoryColor(reminder.category),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: onEdit, // ← callback nuevo
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(ReminderCategory cat) {
    return switch (cat) {
      ReminderCategory.habit => Icons.repeat_rounded,
      ReminderCategory.exercise => Icons.fitness_center_rounded,
      ReminderCategory.hydration => Icons.water_drop_rounded,
      ReminderCategory.rest => Icons.bedtime_rounded,
      ReminderCategory.productivity => Icons.school_rounded,
      ReminderCategory.other => Icons.event_note_rounded,
    };
  }

  Color _categoryColor(ReminderCategory cat) {
    return switch (cat) {
      ReminderCategory.habit => AppTheme.primary,
      ReminderCategory.exercise => AppTheme.completed,
      ReminderCategory.hydration => const Color(0xFF0984E3),
      ReminderCategory.rest => const Color(0xFF6C5CE7),
      ReminderCategory.productivity => AppTheme.pending,
      ReminderCategory.other => AppTheme.textSecondary,
    };
  }
}

// ── Formulario de nuevo recordatorio ────────────────────────────────────────

class _ReminderForm extends StatefulWidget {
  final DateTime day;
  final Reminder? editing;
  final void Function(Reminder) onSave;
  final VoidCallback onCancel;

  const _ReminderForm({
    required this.day,
    this.editing,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TimeOfDay? _selectedTime;
  ReminderCategory _selectedCategory = ReminderCategory.other;

  static const _categories = ReminderCategory.values;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _titleCtrl.text = widget.editing!.title;
      _descCtrl.text = widget.editing?.description ?? '';
      _selectedTime = widget.editing!.time;
      _selectedCategory = widget.editing!.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final reminder = Reminder(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: widget.day,
      time: _selectedTime,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _selectedCategory,
    );
    widget.onSave(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Título del recordatorio',
              prefixIcon: const Icon(Icons.title_rounded, size: 20),
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
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Descripción
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(
              hintText: 'Descripción (opcional)',
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
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
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Fila: hora + categoría
          Row(
            children: [
              // Hora
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedTime == null
                              ? 'Sin hora'
                              : _formatTime(_selectedTime!),
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedTime == null
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Categoría
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReminderCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      items: _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(_categoryLabel(cat)),
                            ),
                          )
                          .toList(),
                      onChanged: (cat) {
                        if (cat != null) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botones guardar / cancelar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.divider),
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
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
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

  String _categoryLabel(ReminderCategory cat) {
    return switch (cat) {
      ReminderCategory.habit => 'Hábito',
      ReminderCategory.exercise => 'Ejercicio',
      ReminderCategory.hydration => 'Hidratación',
      ReminderCategory.rest => 'Descanso',
      ReminderCategory.productivity => 'Productividad',
      ReminderCategory.other => 'Otro',
    };
  }
}
