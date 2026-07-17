import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vita_habit/domain/entities/user_profile.dart';
import 'package:vita_habit/presentation/providers/auth/auth_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileNotifier(this._client) : super(const AsyncValue.loading()) {
    load();
  }

  final SupabaseClient _client;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final row = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      state = AsyncValue.data(
        UserProfile(
          id: row['id'] as String,
          name: row['name'] as String? ?? 'Usuario',
          joinedAt: DateTime.parse(row['created_at'] as String),
          heightCm: (row['height_cm'] as num?)?.toDouble() ?? 170,
          weightKg: (row['weight_kg'] as num?)?.toDouble() ?? 70,
          ageYears: row['age_years'] as int? ?? 25,
          globalStreakDays: row['global_streak_days'] as int? ?? 0,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update({
    String? name,
    double? heightCm,
    double? weightKg,
    int? ageYears,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (heightCm != null) updates['height_cm'] = heightCm;
    if (weightKg != null) updates['weight_kg'] = weightKg;
    if (ageYears != null) updates['age_years'] = ageYears;

    await _client.from('profiles').update(updates).eq('id', user.id);
    await load();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return ProfileNotifier(ref.watch(supabaseClientProvider));
    });
