import 'package:flutter/material.dart';

enum ReminderCategory { habit, exercise, hydration, rest, productivity, other }

class Reminder {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay? time;
  final String? description;
  final ReminderCategory category;

  const Reminder({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.description,
    this.category = ReminderCategory.other,
  });

  /// Clave normalizada para agrupar por día (ignora hora)
  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  String get categoryLabel {
    return switch (category) {
      ReminderCategory.habit => 'Hábito',
      ReminderCategory.exercise => 'Ejercicio',
      ReminderCategory.hydration => 'Hidratación',
      ReminderCategory.rest => 'Descanso',
      ReminderCategory.productivity => 'Productividad',
      ReminderCategory.other => 'Otro',
    };
  }

  String get timeLabel {
    if (time == null) return 'Sin hora';
    final h = time!.hour;
    final m = time!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }
}
