-- Aligne un projet ayant déjà exécuté 001 avec le moteur de sync D14-D15.

-- updated_at vient de chaque appareil et sert au Last Write Wins. Une date
-- future est bornée à l'heure serveur pour éviter de bloquer les autres appareils.
DROP TRIGGER IF EXISTS tasks_updated_at ON public.tasks;

-- Sécurise et qualifie le trigger exécuté lors de la création d'un compte.
CREATE OR REPLACE FUNCTION public.create_default_user_settings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.create_default_user_settings();

-- Upsert atomique : une écriture hors ligne ancienne ne peut jamais écraser
-- une version cloud plus récente. L'identité vient du JWT, jamais du client.
CREATE OR REPLACE FUNCTION public.sync_task(p_task JSONB)
RETURNS public.tasks
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    canonical public.tasks;
    task_id UUID := (p_task->>'id')::UUID;
    task_updated_at TIMESTAMPTZ :=
        LEAST((p_task->>'updated_at')::TIMESTAMPTZ, clock_timestamp());
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentification requise';
    END IF;

    INSERT INTO public.tasks (
        id, user_id, title, status, category, planned_date, reminder_at,
        sort_order, sync_version, created_at, updated_at, completed_at,
        deleted_at
    )
    VALUES (
        task_id,
        auth.uid(),
        p_task->>'title',
        (p_task->>'status')::public.task_status,
        (p_task->>'category')::public.task_category,
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
    WHERE public.tasks.user_id = auth.uid()
      AND EXCLUDED.updated_at > public.tasks.updated_at
    RETURNING * INTO canonical;

    IF canonical.id IS NULL THEN
        SELECT *
        INTO canonical
        FROM public.tasks
        WHERE id = task_id AND user_id = auth.uid();
    END IF;

    IF canonical.id IS NULL THEN
        RAISE EXCEPTION 'Tâche inaccessible: %', task_id;
    END IF;

    RETURN canonical;
END;
$$;

GRANT EXECUTE ON FUNCTION public.sync_task(JSONB) TO authenticated;
