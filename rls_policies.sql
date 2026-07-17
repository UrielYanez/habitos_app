-- Habilitar RLS en todas las tablas
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Políticas para 'habits'
CREATE POLICY "Users can only select their own habits"
ON habits FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own habits"
ON habits FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own habits"
ON habits FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own habits"
ON habits FOR DELETE
USING (auth.uid() = user_id);

-- Políticas para 'reminders'
CREATE POLICY "Users can only select their own reminders"
ON reminders FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own reminders"
ON reminders FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own reminders"
ON reminders FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own reminders"
ON reminders FOR DELETE
USING (auth.uid() = user_id);

-- Políticas para 'user_profiles'
CREATE POLICY "Users can only select their own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can only insert their own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can only update their own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can only delete their own profile"
ON user_profiles FOR DELETE
USING (auth.uid() = id);
