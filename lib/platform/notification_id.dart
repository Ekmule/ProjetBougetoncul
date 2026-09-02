/// Identifiant stable pour les notifications locales (1 tâche = 1 id).
int notificationIdForTask(String taskId) {
  return taskId.hashCode & 0x7FFFFFFF;
}
