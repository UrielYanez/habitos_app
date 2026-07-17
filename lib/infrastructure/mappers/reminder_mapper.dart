import 'package:flutter/material.dart';
import 'package:vita_habit/domain/entities/reminder.dart';
import 'package:vita_habit/infrastructure/utils/sanitizer.dart';

class ReminderMapper {
  // ── Desde Supabase ────────────────────────────────────────────────────────
  static Reminder fromSupabase(Map<String, dynamic> json) {
    TimeOfDay? time;
    final timeStr = json['time_of_day'] as String?;
    if (timeStr != null) {
      final parts = timeStr.split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: time,
      description: json['description'] as String?,
      category: _parseCategory(json['category'] as String? ?? 'other'),
    );
  }

  // ── Hacia Supabase ────────────────────────────────────────────────────────
  static Map<String, dynamic> toSupabase(Reminder r, String userId) {
    String? timeStr;
    if (r.time != null) {
      final h = r.time!.hour.toString().padLeft(2, '0');
      final m = r.time!.minute.toString().padLeft(2, '0');
      timeStr = '$h:$m:00';
    }

    return {
      'user_id': userId,
      'title': Sanitizer.escapeHtml(r.title),
      'date':
          '${r.date.year}-'
          '${r.date.month.toString().padLeft(2, '0')}-'
          '${r.date.day.toString().padLeft(2, '0')}',
      'time_of_day': timeStr,
      'description': r.description != null
          ? Sanitizer.escapeHtml(r.description!)
          : null,
      'category': r.category.name,
    };
  }

  // ── Helper privado ────────────────────────────────────────────────────────
  static ReminderCategory _parseCategory(String raw) => ReminderCategory.values
      .firstWhere((c) => c.name == raw, orElse: () => ReminderCategory.other);
}
