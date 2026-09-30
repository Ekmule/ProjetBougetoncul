import 'package:shared_preferences/shared_preferences.dart';

class SyncMetadataStore {
  SyncMetadataStore(this._preferences);

  final SharedPreferences _preferences;

  bool isInitialMergeCompleted(String userId) {
    return _preferences.getBool(_key(userId)) ?? false;
  }

  Future<void> markInitialMergeCompleted(String userId) {
    return _preferences.setBool(_key(userId), true);
  }

  String _key(String userId) => 'sync_initial_merge_completed_$userId';
}
