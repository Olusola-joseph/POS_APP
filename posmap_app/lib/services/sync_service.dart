import 'package:supabase_flutter/supabase_flutter.dart';
import 'offline_storage_service.dart';
import '../models/pos_operator.dart';

class SyncService {
  final SupabaseClient _client = Supabase.instance.client;
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  // Sync all pending operations when connection is available
  Future<void> syncPendingOperations() async {
    try {
      print('Starting sync process...');
      
      // Get all unsynced items from local storage
      final unsyncedItems = await _offlineStorage.getUnsyncedItems();
      
      if (unsyncedItems.isEmpty) {
        print('No pending sync operations');
        return;
      }
      
      print('Found ${unsyncedItems.length} pending sync operations');
      
      for (final item in unsyncedItems) {
        try {
          await _processSyncItem(item);
          await _offlineStorage.markAsSynced(item['id']);
          print('Successfully synced item ${item['id']}');
        } catch (e) {
          print('Failed to sync item ${item['id']}: $e');
          // Don't mark as synced if failed - will retry next time
        }
      }
      
      print('Sync process completed');
    } catch (error) {
      print('Error during sync: $error');
      rethrow;
    }
  }

  // Process individual sync item
  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final action = item['action'];
    final data = item['data'] as Map<String, dynamic>;
    
    switch (action) {
      case 'create':
        await _handleCreate(data);
        break;
      case 'update':
        await _handleUpdate(data);
        break;
      case 'delete':
        await _handleDelete(data);
        break;
      default:
        throw Exception('Unknown sync action: $action');
    }
  }

  // Handle create operation
  Future<void> _handleCreate(Map<String, dynamic> data) async {
    final response = await _client
        .from('pos_operators')
        .insert(data)
        .select();

    // Update local record with server ID
    final serverId = response[0]['id'] as int;
    final localOperator = PosOperator.fromJson(data);
    final updatedOperator = localOperator.copyWith(id: serverId);
    
    await _offlineStorage.savePosOperatorLocal(updatedOperator);
  }

  // Handle update operation
  Future<void> _handleUpdate(Map<String, dynamic> data) async {
    final id = data['id'] as int?;
    if (id == null) {
      throw Exception('Cannot update record without ID');
    }
    
    await _client
        .from('pos_operators')
        .update(data)
        .eq('id', id);
  }

  // Handle delete operation
  Future<void> _handleDelete(Map<String, dynamic> data) async {
    final id = data['id'] as int?;
    if (id == null) {
      throw Exception('Cannot delete record without ID');
    }
    
    await _client
        .from('pos_operators')
        .delete()
        .eq('id', id);
  }

  // Download latest data from server to local storage
  Future<void> downloadLatestData() async {
    try {
      print('Downloading latest data from server...');
      
      // Fetch all POS operators from server
      final response = await _client
          .from('pos_operators')
          .select('*')
          .order('updated_at', ascending: false);

      // Clear local storage and repopulate with fresh data
      await _offlineStorage.clearAllData();
      
      for (final item in response) {
        final operator = PosOperator.fromJson(item);
        await _offlineStorage.savePosOperatorLocal(operator);
      }
      
      print('Downloaded ${response.length} records from server');
    } catch (error) {
      print('Error downloading data: $error');
      rethrow;
    }
  }

  // Check if device is online
  Future<bool> isOnline() async {
    try {
      // Simple connectivity check by trying to ping Supabase
      await _client.from('pos_operators').select('id').limit(1);
      return true;
    } catch (e) {
      print('Device appears to be offline: $e');
      return false;
    }
  }

  // Manual sync trigger
  Future<void> manualSync() async {
    final isDeviceOnline = await isOnline();
    
    if (isDeviceOnline) {
      await syncPendingOperations();
      await downloadLatestData();
    } else {
      print('Device is offline, sync postponed');
    }
  }
}