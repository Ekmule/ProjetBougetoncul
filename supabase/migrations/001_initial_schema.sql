-- MYA — Schéma initial Supabase
-- Version : 1.0
-- Date : 2026-08-23
--
-- Instructions :
-- 1. Créer un projet sur https://supabase.com
-- 2. Aller dans SQL Editor → New query
-- 3. Coller ce fichier entier et cliquer Run
-- 4. Vérifier dans Table Editor que les tables tasks et user_settings existent
-- 5. Vérifier dans Authentication → Policies que RLS est actif

-- =============================================================================
-- EXTENSIONS
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- TYPES ÉNUMÉRÉS
-- =============================================================================

CREATE TYPE task_status AS ENUM ('active', 'completed', 'deleted');

CREATE TYPE task_category AS ENUM ('must_do', 'today', 'next', 'someday');

CREATE TYPE notification_style AS ENUM ('normal', 'humorous', 'brutal');

-- =============================================================================
-- TABLE : tasks
-- =============================================================================
-- Stocke les tâches synchronisées de chaque utilisateur.
-- Chaque tâche appartient à un seul utilisateur (user_id = auth.uid()).

CREATE TABLE tasks (
    id              UUID            PRIMARY KEY,
    user_id         UUID            NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title           TEXT            NOT NULL CHECK (char_length(trim(title)) > 0),
    status          task_status     NOT NULL DEFAULT 'active',
    category        task_category   NOT NULL DEFAULT 'next',
    planned_date    DATE,
    reminder_at     TIMESTAMPTZ,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    sync_version    INTEGER         NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    completed_at    TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ
);

-- Index pour les requêtes fréquentes
CREATE INDEX idx_tasks_user_id        ON tasks (user_id);
CREATE INDEX idx_tasks_user_status    ON tasks (user_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_user_updated   ON tasks (user_id, updated_at DESC);
CREATE INDEX idx_tasks_reminder       ON tasks (reminder_at) WHERE reminder_at IS NOT NULL AND status = 'active';

-- Mise à jour automatique de updated_at pour les paramètres serveur.
-- Les tâches conservent le timestamp produit par l'appareil pour permettre
-- la résolution Last Write Wins entre plusieurs appareils hors ligne. Le RPC
-- borne toutefois les dates futures à l'heure serveur.
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- TABLE : user_settings
-- =============================================================================
-- Préférences utilisateur synchronisées entre appareils.
-- Une seule ligne par utilisateur.

CREATE TABLE user_settings (
    user_id                     UUID            PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    category_label_must_do      TEXT            NOT NULL DEFAULT 'BOUGE TON GROS CUL',
    category_label_today        TEXT            NOT NULL DEFAULT 'AUJOURD''HUI',
    category_label_next         TEXT            NOT NULL DEFAULT 'ENSUITE',
    category_label_someday      TEXT            NOT NULL DEFAULT 'À FAIRE SI J''AI LE TEMPS',
    humor_enabled               BOOLEAN         NOT NULL DEFAULT true,
    history_retention_days      INTEGER         NOT NULL DEFAULT 7 CHECK (history_retention_days BETWEEN 1 AND 7),
    notification_style          notification_style NOT NULL DEFAULT 'normal',
    theme_preference            TEXT            NOT NULL DEFAULT 'system' CHECK (theme_preference IN ('system', 'light', 'dark')),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT now()
);

CREATE TRIGGER user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Créer automatiquement les paramètres par défaut à l'inscription
CREATE OR REPLACE FUNCTION create_default_user_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_default_user_settings();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================
-- Principe : un utilisateur ne voit et ne modifie que SES données.

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- tasks : lecture
CREATE POLICY "tasks_select_own"
    ON tasks FOR SELECT
    USING (auth.uid() = user_id);

-- tasks : insertion
CREATE POLICY "tasks_insert_own"
    ON tasks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- tasks : mise à jour
CREATE POLICY "tasks_update_own"
    ON tasks FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- tasks : suppression (soft delete via UPDATE de deleted_at, ou DELETE physique)
CREATE POLICY "tasks_delete_own"
    ON tasks FOR DELETE
    USING (auth.uid() = user_id);

-- user_settings : lecture
CREATE POLICY "user_settings_select_own"
    ON user_settings FOR SELECT
    USING (auth.uid() = user_id);

-- user_settings : mise à jour
CREATE POLICY "user_settings_update_own"
    ON user_settings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- user_settings : insertion (normalement via trigger, mais au cas où)
CREATE POLICY "user_settings_insert_own"
    ON user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Upsert atomique protégé par LWW. L'identité vient du JWT.
CREATE OR REPLACE FUNCTION sync_task(p_task JSONB)
RETURNS tasks
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    canonical tasks;
    task_id UUID := (p_task->>'id')::UUID;
    task_updated_at TIMESTAMPTZ :=
        LEAST((p_task->>'updated_at')::TIMESTAMPTZ, clock_timestamp());
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentification requise';
    END IF;

    INSERT INTO tasks (
        id, user_id, title, status, category, planned_date, reminder_at,
        sort_order, sync_version, created_at, updated_at, completed_at,
        deleted_at
    )
    VALUES (
        task_id, auth.uid(), p_task->>'title',
        (p_task->>'status')::task_status,
        (p_task->>'category')::task_category,
        (p_task->>'planned_date')::DATE,
        (p_task->>'reminder_at')::TIMESTAMPTZ,
        COALESCE((p_task->>'sort_order')::INTEGER, 0),
        COALESCE((p_task->>'sync_version')::INTEGER, 1),
        (p_task->>'created_at')::TIMESTAMPTZ,
        task_updated_at,
        (p_task->>'completed_at')::TIMESTAMPTZ,
        (p_task->>'deleted_at')::TIMESTAMPTZ
    )
    ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        status = EXCLUDED.status,
        category = EXCLUDED.category,
        planned_date = EXCLUDED.planned_date,
        reminder_at = EXCLUDED.reminder_at,
        sort_order = EXCLUDED.sort_order,
        sync_version = EXCLUDED.sync_version,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at,
        completed_at = EXCLUDED.completed_at,
        deleted_at = EXCLUDED.deleted_at
    WHERE tasks.user_id = auth.uid()
      AND EXCLUDED.updated_at > tasks.updated_at
    RETURNING * INTO canonical;

    IF canonical.id IS NULL THEN
        SELECT * INTO canonical
        FROM tasks
        WHERE id = task_id AND user_id = auth.uid();
    END IF;

    IF canonical.id IS NULL THEN
        RAISE EXCEPTION 'Tâche inaccessible: %', task_id;
    END IF;

    RETURN canonical;
END;
$$;

GRANT EXECUTE ON FUNCTION sync_task(JSONB) TO authenticated;

-- =============================================================================
-- REALTIME
-- =============================================================================
-- Permet à l'app de recevoir les changements distants en quasi temps réel.

ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE user_settings;

-- =============================================================================
-- VÉRIFICATION (optionnel — à exécuter après le script)
-- =============================================================================
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
-- SELECT * FROM pg_policies WHERE tablename IN ('tasks', 'user_settings');
