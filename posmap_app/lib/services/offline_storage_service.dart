import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/pos_operator.dart';

class OfflineStorageService {
  static const String _posOperatorsBox = 'pos_operators_box';
  static const String _syncQueueBox = 'sync_queue_box';
  
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      
      // Register adapters if we had custom objects
      // Hive.registerAdapter(PosOperatorAdapter());
      
      await Hive.openBox<PosOperator>(_posOperatorsBox);
      await Hive.openBox<Map<String, dynamic>>(_syncQueueBox);
      
      _initialized = true;
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  // Save POS operator to local storage
  Future<void> savePosOperatorLocal(PosOperator operator) async {
    await init();
    final box = Hive.box<PosOperator>(_posOperatorsBox);
    
    // If operator has an ID, update existing, otherwise add new
    if (operator.id != null) {
      await box.put(operator.id, operator);
    } else {
      // Generate a temporary ID for offline storage
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final newOperator = operator.copyWith(id: tempId);
      await box.add(newOperator);
    }
  }

  // Add registration to sync queue
  Future<void> addToSyncQueue(PosOperator operator, String action) async {
    await init();
    final box = Hive.box<Map<String, dynamic>>(_syncQueueBox);
    
    final syncItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'action': action, // 'create', 'update', 'delete'
      'data': operator.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };
    
    await box.add(syncItem);
  }

  // Get all unsynced items
  Future<List<Map<String, dynamic>>> getUnsyncedItems() async {
    await init();
    final box = Hive.box<Map<String, dynamic>>(_syncQueueBox);
    
    final unsyncedItems = <Map<String, dynamic>>[];
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i) as Map<String, dynamic>;
      if (item['synced'] == false) {
        unsyncedItems.add(item);
      }
    }
    
    return unsyncedItems;
  }

  // Mark item as synced
  Future<void> markAsSynced(int id) async {
    await init();
    final box = Hive.box<Map<String, dynamic>>(_syncQueueBox);
    
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i) as Map<String, dynamic>;
      if (item['id'] == id) {
        final updatedItem = Map<String, dynamic>.from(item);
        updatedItem['synced'] = true;
        await box.putAt(i, updatedItem);
        break;
      }
    }
  }

  // Get all local POS operators
  Future<List<PosOperator>> getAllLocalPosOperators() async {
    await init();
    final box = Hive.box<PosOperator>(_posOperatorsBox);
    
    final operators = <PosOperator>[];
    for (int i = 0; i < box.length; i++) {
      final operator = box.getAt(i);
      if (operator != null) {
        operators.add(operator);
      }
    }
    
    // Sort by creation date (newest first)
    operators.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return operators;
  }

  // Get POS operator by ID
  Future<PosOperator?> getPosOperatorById(int id) async {
    await init();
    final box = Hive.box<PosOperator>(_posOperatorsBox);
    
    return box.get(id);
  }

  // Delete POS operator
  Future<void> deletePosOperator(int id) async {
    await init();
    final box = Hive.box<PosOperator>(_posOperatorsBox);
    
    await box.delete(id);
  }

  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    await init();
    final posBox = Hive.box<PosOperator>(_posOperatorsBox);
    final syncBox = Hive.box<Map<String, dynamic>>(_syncQueueBox);
    
    await posBox.clear();
    await syncBox.clear();
  }

  // Close boxes
  Future<void> closeBoxes() async {
    if (_initialized) {
      await Hive.close();
      _initialized = false;
    }
  }
}