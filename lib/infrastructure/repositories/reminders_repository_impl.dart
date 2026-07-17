import 'package:vita_habit/domain/datasources/reminders_datasource.dart';
import 'package:vita_habit/domain/entities/reminder.dart';
import 'package:vita_habit/domain/repositories/reminders_repository.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersDatasource datasource;

  const RemindersRepositoryImpl(this.datasource);

  @override
  Future<List<Reminder>> getAll() => datasource.getAll();

  @override
  Future<List<Reminder>> getByDate(DateTime date) => datasource.getByDate(date);

  @override
  Future<Reminder> create(Reminder reminder) => datasource.create(reminder);

  @override
  Future<void> delete(String id) => datasource.delete(id);
}
