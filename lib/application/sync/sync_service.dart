/// Synchronisation bidirectionnelle locale ↔ Supabase — prévu en D14–D15.
abstract class SyncService {
  Future<void> syncNow();
}
