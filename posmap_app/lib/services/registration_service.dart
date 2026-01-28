import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:posmap/models/pos_operator.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistrationService {
  final SupabaseClient _client = Supabase.instance.client;
  final Dio _dio = Dio();

  // Save registration to local storage (Hive) for offline support
  Future<void> saveRegistration(PosOperator posOperator) async {
    try {
      // Upload images to storage if they exist
      String? selfieUrl, signageUrl, idUrl;
      
      if (posOperator.selfieImage != null) {
        selfieUrl = await _uploadImage(posOperator.selfieImage!, 'selfies');
      }
      if (posOperator.businessSignageImage != null) {
        signageUrl = await _uploadImage(posOperator.businessSignageImage!, 'signages');
      }
      if (posOperator.idDocumentImage != null) {
        idUrl = await _uploadImage(posOperator.idDocumentImage!, 'ids');
      }

      // Update the operator with the URLs
      final updatedOperator = posOperator.copyWith(
        selfieImage: selfieUrl,
        businessSignageImage: signageUrl,
        idDocumentImage: idUrl,
      );

      // Insert into Supabase
      final response = await _client
          .from('pos_operators')
          .insert(updatedOperator.toJson())
          .select();

      print('Registration saved successfully: ${response[0]['id']}');
    } catch (error) {
      print('Error saving registration: $error');
      rethrow;
    }
  }

  // Upload image to Supabase storage
  Future<String?> _uploadImage(String imagePath, String folder) async {
    try {
      final file = File(imagePath);
      final fileName = '${folder}/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
      
      // Upload file to Supabase storage
      final response = await _client.storage.from('pos-operator-images').upload(
            fileName,
            file.readAsBytesSync(),
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _client.storage.from('pos-operator-images').getPublicUrl(fileName);
      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return null;
    }
  }

  // Check for duplicates using BVN or phone number
  Future<bool> checkForDuplicates(String phoneNumber, {String? bvn}) async {
    try {
      var query = _client
          .from('pos_operators')
          .select('id')
          .eq('phone_number', phoneNumber);

      if (bvn != null) {
        query = query.or('bvn.eq.$bvn,phone_number.eq.$phoneNumber');
      }

      final response = await query;
      return response.isNotEmpty;
    } catch (error) {
      print('Error checking for duplicates: $error');
      return false;
    }
  }

  // Get all registered POS operators
  Future<List<PosOperator>> getAllPosOperators() async {
    try {
      final response = await _client
          .from('pos_operators')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => PosOperator.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching POS operators: $error');
      rethrow;
    }
  }

  // Get POS operators by location (ward/town)
  Future<List<PosOperator>> getPosOperatorsByLocation(String location) async {
    try {
      final response = await _client
          .from('pos_operators')
          .select('*')
          .ilike('location_landmark', '%$location%')
          .order('created_at', ascending: false);

      return response.map((json) => PosOperator.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching POS operators by location: $error');
      rethrow;
    }
  }

  // Get POS operators by tier
  Future<List<PosOperator>> getPosOperatorsByTier(String tier) async {
    try {
      final response = await _client
          .from('pos_operators')
          .select('*')
          .eq('tier', tier)
          .order('created_at', ascending: false);

      return response.map((json) => PosOperator.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching POS operators by tier: $error');
      rethrow;
    }
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getRegistrationStats() async {
    try {
      // Total registrations
      final totalResponse = await _client
          .from('pos_operators')
          .select('*', count: CountOption.exact);

      // Today's registrations
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final todayResponse = await _client
          .from('pos_operators')
          .select('*', count: CountOption.exact)
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String());

      // By tier
      final tierResponse = await _client.rpc('get_pos_by_tier', params: {});

      // By location
      final locationResponse = await _client.rpc('get_pos_by_location', params: {});

      return {
        'totalRegistrations': totalResponse.length,
        'todaysRegistrations': todayResponse.length,
        'byTier': tierResponse,
        'byLocation': locationResponse,
      };
    } catch (error) {
      print('Error fetching stats: $error');
      rethrow;
    }
  }

  // Sync offline data when connection is available
  Future<void> syncOfflineData() async {
    // Implementation for syncing offline stored data
    // This would involve checking for locally stored registrations
    // and uploading them to the server when online
    print('Syncing offline data...');
  }
}