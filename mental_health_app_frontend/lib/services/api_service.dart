import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';   

class ApiService {
  final _storage = const FlutterSecureStorage();
  static String _baseUrl = 'https://maa-backend-u6e5.onrender.com'; 
  String get baseUrl => _baseUrl;

  // Initialize URL from storage on startup
  Future<void> loadBaseUrl() async {
    final savedUrl = await _storage.read(key: 'server_ip');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      // FORCE MIGRATION: If old IP is found, ignore it and use the new default
      if (savedUrl.contains('10.64.217.189') || savedUrl.contains('10.123.238.189') || savedUrl.contains('192.168.48.146') || savedUrl.contains('192.168.48.147') || savedUrl.contains('192.168.61.204') || savedUrl.contains('192.168.48.177') || savedUrl.contains('10.20.228.189') || savedUrl.contains('10.142.80.189')) {
        print('⚠️ Detected old invalid IP in storage. Overwriting with new default.');
        await _storage.delete(key: 'server_ip'); // Clear it so it uses default
        _baseUrl = 'https://maa-backend-u6e5.onrender.com'; // Enforce new one
      } else {
        _baseUrl = savedUrl.trim();
        print('✅ Loaded saved server URL: $_baseUrl');
      }
    }
  }

  // Update and save new URL
  Future<void> updateBaseUrl(String newUrl) async {
    newUrl = newUrl.trim();
    
    // Remove existing schemes to sanitize
    if (newUrl.startsWith('http://')) newUrl = newUrl.substring(7);
    if (newUrl.startsWith('https://')) newUrl = newUrl.substring(8);
    
    // Trim again to remove spaces like 'http:// 192...'
    newUrl = newUrl.trim();
    
    // Remove trailing slash if present
    if (newUrl.endsWith('/')) {
      newUrl = newUrl.substring(0, newUrl.length - 1);
    }
    
    // Add http protocol (force http for now as per previous logic)
    newUrl = 'http://$newUrl';
    
    _baseUrl = newUrl;
    await _storage.write(key: 'server_ip', value: _baseUrl);
    print('✅ Updated server URL to: $_baseUrl');
  }

  // MARK: Authentication Methods
  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['access_token']);
        await _storage.write(key: 'user_id', value: data['user_id'].toString());
        await _storage.write(key: 'username', value: data['username']);
      } else {
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'username');
      print('✅ Logout successful: Session cleared');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String age,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    String? gender,
    required String guardianName,
    required String guardianRelationship,
    required String guardianPhoneNumber,
    required String guardianEmail,
    PlatformFile? medicalHistory,
  }) async {
    try {
      print('🚀 Initiating Registration...');
      print('Server URL: $_baseUrl');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/auth/register/'),
      );

      // Trim and add fields
      request.fields.addAll({
        'name': name.trim(),
        'age': age.trim(),
        'phone_number': phoneNumber.trim(),
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
        if (gender != null) 'gender': gender,
        'guardian_name': guardianName.trim(),
        'guardian_relationship': guardianRelationship.trim(),
        'guardian_phone_number': guardianPhoneNumber.trim(),
        'guardian_email': guardianEmail.trim(),
      });

      print('📝 Registration Fields: ${request.fields}');

      if (medicalHistory != null && medicalHistory.path != null) {
        print('📂 Attaching Medical History: ${medicalHistory.name}');
        if (kIsWeb) {
          if (medicalHistory.bytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'medical_history',
              medicalHistory.bytes!,
              filename: medicalHistory.name,
            ));
          }
        } else {
           // Mobile: Check if file exists
           final file = File(medicalHistory.path!);
           if (await file.exists()) {
              request.files.add(await http.MultipartFile.fromPath(
                'medical_history',
                medicalHistory.path!,
                filename: medicalHistory.name,
              ));
           } else {
             print('⚠️ Medical history file path not found: ${medicalHistory.path}');
           }
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('📩 Registration Response (${response.statusCode}): $responseBody');

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        await _storage.write(key: 'jwt_token', value: data['access_token']);
        await _storage.write(key: 'user_id', value: data['user_id'].toString());
        await _storage.write(key: 'username', value: data['username']);
      } else {
        // Try to parse error message
        try {
           final errData = jsonDecode(responseBody);
           if (errData['error'] != null) {
             throw Exception(errData['error']);
           }
        } catch (_) {}
        throw Exception('Registration failed: $responseBody');
      }
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode != 200) {
        throw Exception('Reset failed: ${response.body}');
      }
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // MARK: Meditation & Yoga Methods
  Future<List<dynamic>> getMeditationSessions() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      print('🔍 DEBUG: Fetching meditations from $_baseUrl/api/meditations/');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/meditations/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('🔍 DEBUG: Meditations Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🔍 DEBUG: Found ${data.length} meditation sessions');
        for (var item in data) {
          item['category_id'] = item['category_id'] ?? null;
        }
        return data;
      } else {
        print('❌ DEBUG: Meditations Error Body: ${response.body}');
        throw Exception('Failed to load meditations: ${response.body}');
      }
    } catch (e) {
      print('❌ DEBUG: getMeditationSessions Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMeditationDetail(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/meditations/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['category_id'] = data['category_id'] ?? null;
        return data;
      } else {
        throw Exception('Failed to load meditation detail: ${response.body}');
      }
    } catch (e) {
      print('Get meditation detail error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getYogaSessions() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/yoga/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          item['type_id'] = item['type_id'] ?? null;
        }
        return data;
      } else {
        throw Exception('Failed to load yoga sessions: ${response.body}');
      }
    } catch (e) {
      print('Get yoga sessions error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getYogaDetail(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/yoga/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load yoga detail: ${response.body}');
      }
    } catch (e) {
      print('Get yoga detail error: $e');
      rethrow;
    }
  }

  // MARK: Background Music
  Future<List<dynamic>> getBackgroundMusic() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/background-music/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load background music: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Get background music error: $e');
      rethrow;
    }
  }

  // MARK: Audio Upload
  Future<void> uploadAudio(
    String audioType,
    String title,
    String description,
    int duration,
    File file, {
    int? categoryId,
    String? emoji,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/upload/audio/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll({
        'audio_type': audioType,
        'title': title,
        'description': description,
        'duration': duration.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (emoji != null) 'emoji': emoji,
      });
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'audio_file',
          bytes,
          filename: file.path.split('/').last,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'audio_file',
          file.path,
          filename: file.path.split('/').last,
        ));
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode != 201) {
        throw Exception('Upload failed: $responseBody');
      }
    } catch (e) {
      print('Upload audio error: $e');
      rethrow;
    }
  }

  // MARK: Session Logging
  Future<void> logPanicSession(Map<String, bool> actions) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/panic/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'actions': actions}),
      );
      if (response.statusCode != 201) {
        throw Exception('Logging failed: ${response.body}');
      }
    } catch (e) {
      print('Log panic session error: $e');
      rethrow;
    }
  }

  Future<void> logCalmingSession(String actions) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/calming/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'actions': actions}),
      );
      if (response.statusCode != 201) {
        throw Exception('Logging failed: ${response.body}');
      }
    } catch (e) {
      print('Log calming session error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logGroundingSession({
    required String fiveSee,
    required String fourTouch,
    required String threeHear,
    required String twoSmell,
    required String oneTaste,
    String? feedback,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/grounding/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'five_see': fiveSee,
          'four_touch': fourTouch,
          'three_hear': threeHear,
          'two_smell': twoSmell,
          'one_taste': oneTaste,
          if (feedback != null) 'feedback': feedback,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Logging failed: ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('Log grounding session error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logStressBusterSession({
    required int duration,
    String? note,
    String? voicePath,
    Uint8List? voiceBytes,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/sessions/stress-buster/'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['duration'] = duration.toString();
      request.fields['session_type'] = 'stress_buster';
      
      if (note != null && note.isNotEmpty) {
        request.fields['note_text'] = note;
      }
      
      // Handle Voice File (Bytes for Web, Path for Mobile)
      if (voiceBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'voice_file',
          voiceBytes,
          filename: 'stress_buster_audio.webm', // Required for recognition on web
        ));
      } else if (voicePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'voice_file',
          voicePath,
        ));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Logged Stress Buster. Feedback: ${data['feedback']}');
        return data; 
      } else {
        throw Exception('Failed to log session: ${response.body}');
      }
    } catch (e) {
      print('Log stress buster error: $e');
      rethrow;
    }
  }

  // MARK: User Preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/user/preferences/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user preferences: ${response.body}');
      }
    } catch (e) {
      print('Get user preferences error: $e');
      rethrow;
    }
  }

  Future<void> updateUserPreferences(bool meditationMusicOn) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/preferences/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'meditation_music_on': meditationMusicOn}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update preferences: ${response.body}');
      }
    } catch (e) {
      print('Update user preferences error: $e');
      rethrow;
    }
  }

  // MARK: Guardian
  Future<Map<String, dynamic>?> getGuardian() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/guardian/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> guardians = jsonDecode(response.body);
        if (guardians.isNotEmpty) {
          return Map<String, dynamic>.from(guardians[0]);
        }
      }
      return null; // Graceful return if no guardian exists
    } catch (e) {
      print('Get guardian error: $e');
      return null;
    }
  }

  Future<void> updateGuardian({
    required String name,
    required String relationship,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.put(
        Uri.parse('$_baseUrl/api/auth/guardian/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'relationship': relationship,
          'phone_number': phoneNumber,
          'email': email,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update guardian: ${response.body}');
      }
    } catch (e) {
      print('Update guardian error: $e');
      rethrow;
    }
  }

  // MARK: SOS
  Future<Map<String, dynamic>> triggerSOS({String? location}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sos/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (location != null) 'location': location,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('SOS trigger failed: ${response.body}');
      }
    } catch (e) {
      print('Trigger SOS error: $e');
      rethrow;
    }
  }

  // MARK: Mood Tracking
// MARK: Mood Tracking
Future<void> logMood({
  required String moodEmoji,
  required String moodLabel,
  String? note,
  String? tag,
}) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/moods/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'moodEmoji': moodEmoji,
        'moodLabel': moodLabel,
        if (note != null) 'note': note,
        if (tag != null) 'tag': tag,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to log mood: ${response.body}');
    }
  } catch (e) {
    print('Log mood error: $e');
    rethrow;
  }
}
  Future<List<dynamic>> getMoodLogs({String period = 'all', String? tag}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      final queryParams = <String, String>{'period': period};
      if (tag != null) queryParams['tag'] = tag;
      final uri = Uri.parse('$_baseUrl/api/moods/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body;
        } else {
          throw Exception('Expected a list from /api/moods/, got: ${body.runtimeType}');
        }
      } else {
        throw Exception('Failed to load mood logs: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Get mood logs error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMoodSummary() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/moods/summary/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List && body.isNotEmpty) {
          return body[0] as Map<String, dynamic>;
        }
        if (body is Map<String, dynamic>) {
          return body;
        }
        throw Exception('Unexpected response format for mood summary');
      } else {
        throw Exception('Failed to load mood summary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Get mood summary error: $e');
      rethrow;
    }
  }

  // MARK: AFFIRMATIONS - FIXED & SAFE PARSING
  Future<List<Map<String, dynamic>>> getAffirmationCategories() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/affirmations/categories/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('Categories status: ${response.statusCode}');
      print('Categories response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item))
          );
        } else {
          return []; // Return empty list if not List
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Get categories error: $e');
      return []; // Return empty list on error
    }
  }

  Future<List<Map<String, dynamic>>> getGenericAffirmations({int? categoryId}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      String url = '$_baseUrl/api/affirmations/generic/';
      if (categoryId != null) {
        url += '$categoryId/';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('Generic affirmations URL: $url');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ SAFE PARSING: Handle both direct list and wrapped Map
        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item))
          );
        } else if (data is Map) {
          if (data.containsKey('affirmations') && data['affirmations'] is List) {
            return List<Map<String, dynamic>>.from(
              (data['affirmations'] as List).map((item) => Map<String, dynamic>.from(item))
            );
          } else if (data.containsKey('data') && data['data'] is List) {
            return List<Map<String, dynamic>>.from(
              (data['data'] as List).map((item) => Map<String, dynamic>.from(item))
            );
          }
          // If Map but no list wrapper, return empty
          return [];
        }
        return [];
      } else {
        throw Exception('Failed to load affirmations: ${response.statusCode}');
      }
    } catch (e) {
      print('Get generic affirmations error: $e');
      return []; // Return empty list on error
    }
  }

  Future<List<Map<String, dynamic>>> getCustomAffirmations() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/affirmations/custom/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item))
          );
        }
        return [];
      } else {
        throw Exception('Failed to load custom affirmations: ${response.statusCode}');
      }
    } catch (e) {
      print('Get custom affirmations error: $e');
      return [];
    }
  }

  // ✅ New AI Generation Method
  Future<List<String>> generateAIAffirmations({required String context, required int count}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/affirmations/generate-ai/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_context': context, // Can pass chat_history if needed
          'count': count,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['affirmations'] is List) {
          return List<String>.from(data['affirmations']);
        }
        return [];
      } else {
        throw Exception('Failed to generate affirmations: ${response.body}');
      }
    } catch (e) {
      print('Generate AI affirmations error: $e');
      rethrow;
    }
  }

  // ✅ Save Custom Affirmation (Database)
  Future<void> createCustomAffirmation({
    required String text,
    required String focusArea,
    required String challenge, // Optional but good for context
    required String direction, // Optional
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/affirmations/custom/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'focus_area': focusArea,
          'challenge': challenge,
          'positive_direction': direction,
          'affirmation_text': text, // If backend supports direct text override
        }),
      );
      
      if (response.statusCode != 201) {
        // Fallback: If backend generates it, we might just be passing inputs. 
        // But for AI Generated ones, we want to save THAT text.
        // Backend 'CustomAffirmationView.post' I saw earlier generates it from inputs.
        // We probably need to update Backend Post to accept 'affirmation_text' override.
        // I will assume I need to update backend view first if I haven't already.
        // Wait, I checked backend view and it sets affirmation_text based on template.
        // I should update backend view to respect 'affirmation_text' in request if present.
        throw Exception('Failed to save affirmation: ${response.body}');
      }
    } catch (e) {
      print('Create custom affirmation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRandomAffirmation() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/affirmations/random/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        if (data is Map) {
          if (data['message']?.contains('No') == true) {
            return null;
          }
          if (data.containsKey('affirmation')) {
            return Map<String, dynamic>.from(data['affirmation']);
          }
          return Map<String, dynamic>.from(data);
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Get random affirmation error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRandomCustomAffirmation() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/affirmations/random-custom/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['message']?.contains('No custom') == true) {
          return null;
        }
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      print('Get random custom affirmation error: $e');
      return null;
    }
  }


// MARK: MUSIC THERAPY API METHODS
Future<List<Map<String, dynamic>>> getMusicCategories() async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    print('🔍 [MUSIC] Getting categories...');
    final response = await http.get(
      Uri.parse('$_baseUrl/api/music/categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    print('🔍 [MUSIC] Categories status: ${response.statusCode}');
    print('🔍 [MUSIC] Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categories = List<Map<String, dynamic>>.from(data['categories'] ?? []);
      print('✅ [MUSIC] Loaded ${categories.length} categories');
      return categories;
    }
    throw Exception('Failed to load music categories: ${response.statusCode} - ${response.body}');
  } catch (e) {
    print('❌ [MUSIC] Get categories error: $e');
    return [];
  }
}
Future<List<Map<String, dynamic>>> getMusicTracks(int categoryId) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    print('🔍 [MUSIC] Getting tracks for category $categoryId...');
    final response = await http.get(
      Uri.parse('$_baseUrl/api/music/tracks/$categoryId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    print('🔍 [MUSIC] Tracks status: ${response.statusCode}');
    print('🔍 [MUSIC] Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = List<Map<String, dynamic>>.from(data['tracks'] ?? []);
      
      // FIXED: Map 'audio_file' to 'audio_url' + build full URL
      for (var track in tracks) {
        String? audioPath = track['audio_file'] ?? track['audio_url'];
        if (audioPath != null && audioPath.isNotEmpty) {
          if (!audioPath.startsWith('http')) {
            track['audio_url'] = '$_baseUrl$audioPath';  // Full URL for player
          } else {
            track['audio_url'] = audioPath;
          }
        }
      }
      
      print('✅ [MUSIC] Loaded ${tracks.length} tracks with full URLs');
      return tracks;
    }
    throw Exception('Failed to load music tracks: ${response.statusCode} - ${response.body}');
  } catch (e) {
    print('❌ [MUSIC] Get tracks error: $e');
    return [];
  }
}
Future<Map<String, dynamic>> saveMusicSession({
  required int categoryId,
  required List<int> tracksPlayed,
  required String moodChange,
  required String currentEmotion,
  required int sessionDuration,
}) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    print('🔍 [MUSIC] Saving session...');
    print('Category: $categoryId, Mood: $moodChange, Duration: $sessionDuration');
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/music/sessions/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category': categoryId,
        'tracks_played': tracksPlayed,
        'mood_change': moodChange,
        'current_emotion': currentEmotion,
        'session_duration': sessionDuration,
      }),
    );
    
    print('🔍 [MUSIC] Save session status: ${response.statusCode}');
    print('🔍 [MUSIC] Response: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ [MUSIC] Session saved! ID: ${data['id']}');
      return data;
    } else {
      throw Exception('Failed to save music session: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ [MUSIC] Save session error: $e');
    rethrow;
  }
}

// MARK: CBT THERAPY API METHODS
Future<List<Map<String, dynamic>>> getCBTTopics() async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    print('🔍 [CBT] Getting topics...');
    final response = await http.get(
      Uri.parse('$_baseUrl/api/cbt/topics/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    print('🔍 [CBT] Topics status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final topics = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      print('✅ [CBT] Loaded ${topics.length} topics');
      return topics;
    }
    throw Exception('Failed to load CBT topics: ${response.statusCode} - ${response.body}');
  } catch (e) {
    print('❌ [CBT] Get topics error: $e');
    return [];
  }
}

  // MARK: CBT THERAPY API METHODS
  Future<Map<String, dynamic>> saveCBTSession({
    required int topicId,
    required String situation,
    required String automaticThought,
    required String emotions,
    required String evidenceFor,
    required String evidenceAgainst,
    required String balancedThought,
    required int sessionDuration,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        print('No JWT token found');
        throw Exception('No JWT token found - please login again');
      }
      print('Token: ${token.substring(0, 20)}...');

      final requestBody = {
        'topic': topicId,
        'situation': situation.trim(),
        'automatic_thought': automaticThought.trim(),
        'emotions': emotions.trim(),
        'evidence_for': evidenceFor.trim(),
        'evidence_against': evidenceAgainst.trim(),
        'balanced_thought': balancedThought.trim(),
        'session_duration': sessionDuration,
      };
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/cbt/sessions/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Save session status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Session saved! ID: ${data['id']}');
        return data;
      } else {
        throw Exception('Failed to save CBT session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Save session error: $e');
      rethrow;
    }
  }
// MARK: MUSIC & CBT SESSION HISTORY
Future<List<Map<String, dynamic>>> getMusicSessions() async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/music/sessions/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  } catch (e) {
    print('Get music sessions error: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getCBTSessions() async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/cbt/sessions/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  } catch (e) {
    print('Get CBT sessions error: $e');
    return [];
  }
}
  Future<void> deleteCustomAffirmation(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/affirmations/custom/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode != 200) {Future<Map<String, dynamic>> createCustomAffirmation({
  required String focusArea,
  required String challenge,
  required String positiveDirection,
}) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');
    
    print('=== CREATING AFFIRMATION ===');
    print('Focus Area: "$focusArea"');
    print('Challenge: "$challenge"');
    print('Positive Direction: "$positiveDirection"');
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/affirmations/custom/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'focus_area': focusArea.trim(),
        'challenge': challenge.trim(),
        'positive_direction': positiveDirection.trim(),
      }),
    );
    
    print('=== RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ SUCCESS: Created affirmation ID ${data['id']}');
      print('Text: ${data['affirmation_text']}');
      return data;
    } else {
      print('❌ FAILED: ${response.statusCode}');
      throw Exception('Create failed: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ CREATE ERROR: $e');
    rethrow;
  }
}
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete affirmation error: $e');
      rethrow;
    }
  }
  // MARK: Resources Hub API Methods
  Future<List<Map<String, dynamic>>> getDisorders() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      print('🔍 [RESOURCES] Getting disorders...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resources/disorders/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔍 [RESOURCES] Disorders status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final disorders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print('✅ [RESOURCES] Loaded ${disorders.length} disorders');
        return disorders;
      }
      throw Exception('Failed to load disorders: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ [RESOURCES] Get disorders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDisorderDetails(int disorderId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      print('🔍 [RESOURCES] Getting details for disorder $disorderId...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resources/disorders/$disorderId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔍 [RESOURCES] Disorder details status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [RESOURCES] Loaded disorder details');
        return data;
      }
      throw Exception('Failed to load disorder details: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ [RESOURCES] Get disorder details error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getArticles(int disorderId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      print('🔍 [RESOURCES] Getting articles for disorder $disorderId...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resources/articles/$disorderId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔍 [RESOURCES] Articles status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final articles = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print('✅ [RESOURCES] Loaded ${articles.length} articles');
        return articles;
      }
      throw Exception('Failed to load articles: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ [RESOURCES] Get articles error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCopingMethods(int disorderId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      print('🔍 [RESOURCES] Getting coping methods for disorder $disorderId...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resources/coping-methods/$disorderId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔍 [RESOURCES] Coping methods status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final methods = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print('✅ [RESOURCES] Loaded ${methods.length} coping methods');
        return methods;
      }
      throw Exception('Failed to load coping methods: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ [RESOURCES] Get coping methods error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRecoveryRoadmap(int disorderId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      print('🔍 [RESOURCES] Getting recovery roadmap for disorder $disorderId...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resources/roadmap/$disorderId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔍 [RESOURCES] Roadmap status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [RESOURCES] Loaded recovery roadmap');
        return data;
      }
      throw Exception('Failed to load recovery roadmap: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ [RESOURCES] Get roadmap error: $e');
      rethrow;
    }
  }
Future<Map<String, dynamic>> saveTriModalJournal({
  required String text,
  Uint8List? voiceBytes,
  Uint8List? faceBytes,
}) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/journal/tri-modal/'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['text'] = text;

    // ---- VOICE (optional) ----
    if (voiceBytes != null) {
      print('📤 [Frontend] Attaching Voice: ${voiceBytes.length} bytes');
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          voiceBytes,
          filename: "voice.m4a",
        ),
      );
    }

    // ---- IMAGE (optional) ----
    if (faceBytes != null) {
      print('📤 [Frontend] Attaching Face: ${faceBytes.length} bytes');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          faceBytes,
          filename: "selfie.jpg",
        ),
      );
    }

    final response = await request.send().timeout(const Duration(seconds: 300));
    final respStr = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Failed to save journal: $respStr');
    }

    print("✔ Journal saved: $respStr");

    // 👇 RETURN parsed JSON to frontend
    return jsonDecode(respStr);

  } catch (e) {
    print('saveTriModalJournal error: $e');
    rethrow;
  }
}



Future<Map<String, dynamic>?> analyzeFaceFrame(Uint8List imageBytes) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/journal/2/face-track/'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'frame.jpg')
    );

    final response = await request.send().timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    }
  } catch (e) {
    print('Face analysis error: $e');
  }
  return null;
}

Future<Map<String, dynamic>> saveJournal2({
  required String text,
  Uint8List? voiceBytes,
  String? faceBase64,
  String? trackedFaceEmotion,
}) async {
  try {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/journal/2/'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['text'] = text;
    if (faceBase64 != null) {
      request.fields['image'] = faceBase64;
    }
    if (trackedFaceEmotion != null && trackedFaceEmotion.isNotEmpty) {
      request.fields['tracked_face_emotion'] = trackedFaceEmotion;
    }

    if (voiceBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'voice',
          voiceBytes,
          filename: "journal2_voice.wav",
        ),
      );
    }

    final response = await request.send().timeout(const Duration(seconds: 300));
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(respStr);
    } else {
      throw Exception('Failed to save Journal 2: $respStr');
    }
  } catch (e) {
    print('saveJournal2 error: $e');
    rethrow;
  }
}

  // MARK: Therapy Module (Music & Drawing)
  Future<List<dynamic>> getTherapySessions(String type) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/therapy/sessions/?type=$type'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load therapy sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('Get therapy sessions error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTherapySessionDetail(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/therapy/sessions/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load therapy session detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Get therapy session detail error: $e');
      rethrow;
    }
  }

  Future<void> submitTherapyRecord({
    required int sessionId,
    String? moodBefore,
    String? moodAfter,
    String? reflectionNotes,
    Uint8List? drawingBytes, // For Drawing Therapy
    List<Map<String, dynamic>>? answers, // [{question_id: 1, answer_text: "..."}]
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/therapy/records/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['session_id'] = sessionId.toString();
      if (moodBefore != null) request.fields['mood_before'] = moodBefore;
      if (moodAfter != null) request.fields['mood_after'] = moodAfter;
      if (reflectionNotes != null) request.fields['reflection_notes'] = reflectionNotes;
      
      if (answers != null) {
        request.fields['answers'] = jsonEncode(answers);
      }
      
      if (drawingBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'drawing_file',
            drawingBytes,
            filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        );
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode != 201) {
        throw Exception('Failed to submit therapy record: $responseBody');
      }
    } catch (e) {
      print('Submit therapy record error: $e');
      rethrow;
    }
  }




  // MARK: Chat History
  Future<List<dynamic>> getChatHistory({String? mode}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      // Token is optional for history if we rely on session_id, but good practice to send if available
      String url = '$_baseUrl/api/chat/history/';
      if (mode != null) {
        url += '?mode=$mode';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Get chat history error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getChatMessages(String sessionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/history/$sessionId/'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Get chat messages error: $e');
      return [];
    }
  }

  Future<String> sendChatMessage(String sessionId, String query, String mode) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'query': query,
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Chat failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Send chat message error: $e');
      rethrow;
    }
  }

  // MARK: Journal 2 AI Plan
  Future<Map<String, dynamic>> getJournal2LatestPlan() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/journal/2/plan/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Get plan error: $e');
      return {'has_plan': false};
    }
  }

  Future<Map<String, dynamic>> analyzeArtwork(String base64Image) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No JWT token found');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/art-therapy/analyze/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'image_base64': base64Image}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Art analysis error: $e');
      rethrow;
    }
  }
}
