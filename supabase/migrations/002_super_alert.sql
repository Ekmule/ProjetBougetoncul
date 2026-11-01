-- Super alerte MYA : mode renforcé et acquittement synchronisé.
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS super_alert_enabled BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS super_alert_acknowledged_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_tasks_super_alert
  ON tasks (user_id, reminder_at)
  WHERE super_alert_enabled = true
    AND super_alert_acknowledged_at IS NULL
    AND status = 'active';
