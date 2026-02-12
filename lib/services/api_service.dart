import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://wealthbridgeimpex.com/webservice.asmx';

  /// REGISTER USER (GET)
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String address,
    required String landmark,
    required String pincode,
    required String gst,
  }) async {
    final safeLandmark = landmark.trim();

    final String queryString =
        'fullname=${Uri.encodeComponent(fullName.trim())}'
        '&email=${Uri.encodeComponent(email.trim())}'
        '&mobile=${Uri.encodeComponent(mobile.trim())}'
        '&password=${Uri.encodeComponent(password.trim())}'
        '&address=${Uri.encodeComponent(address.trim())}'
        '&landmark=${Uri.encodeComponent(safeLandmark)}'
        '&pincode=${Uri.encodeComponent(pincode.trim())}'
        '&gst=${Uri.encodeComponent(gst.trim())}';

    final Uri url = Uri.parse('$_baseUrl/RegisterUser?$queryString');

    debugPrint('Register API URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      // Remove XML wrapper
      final cleanResponse = response.body
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanResponse);

      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      final String message =
          jsonData['Message']?.toString() ??
          (isSuccess ? 'Registered successfully' : 'Registration failed');

      return {'success': isSuccess, 'message': message};
    } catch (e) {
      debugPrint('Register Error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

 
  /// LOGIN USER (GET)
 Future<Map<String, dynamic>> loginUser({
  required String emailOrMobile,
  required String password,
}) async {
  final Uri url = Uri.parse('$_baseUrl/LoginUser').replace(
    queryParameters: {
      'emailOrMobile': emailOrMobile.trim(),
      'password': password.trim(),
    },
  );

  try {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return {'success': false, 'message': 'Server error'};
    }

    final cleanJson =
        response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

    final bool isSuccess =
        jsonData['Status']?.toString().toLowerCase() == 'success';

    return {
      'success': isSuccess,
      'message': jsonData['Message'] ??
          (isSuccess ? 'Login successful' : 'Login failed'),
      'data': jsonData,
    };
  } catch (e) {
    return {'success': false, 'message': 'Something went wrong'};
  }
}

  /// Update User Profile
  Future<void> updateUserProfile({
    required int id,
    required String fullname,
    required String email,
    required String mobile,
    required String address,
    required String landmark,
    required String pincode,
    required String gst,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/UpdateUserProfile');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
          'fullname': fullname,
          'email': email,
          'mobile': mobile,
          'address': address,
          'landmark': landmark,
          'pincode': pincode,
          'gst': gst,
        },
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw Response: ${response.body}');

      // extract JSON from XML
      final jsonString = response.body.replaceAll(RegExp(r'<[^>]*>'), '');

      final data = jsonDecode(jsonString);

      debugPrint(data['Status']); // Success
      debugPrint(data['Message']); // Profile Updated
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

/// GET USER BY EMAIL OR MOBILE (GET)
Future<Map<String, dynamic>> getUserByEmailOrMobile({
  required String emailOrMobile,
}) async {
  final Uri url = Uri.parse('$_baseUrl/GetUserByEmailOrMobile').replace(
    queryParameters: {
      'value': emailOrMobile.trim(),
    },
  );
   debugPrint('email or mobile:$emailOrMobile');

  debugPrint('GetUser API URL: $url');

  try {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }

    // Remove XML wrapper
    final cleanJson =
        response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    debugPrint('GetUser response: $cleanJson');

    final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

    final bool isSuccess =
        jsonData['Status']?.toString().toLowerCase() == 'success';

    return {
      'success': isSuccess,
      'message': jsonData['Message'],
      'data': jsonData,
    };
  } catch (e) {
    debugPrint('GetUser Error: $e');
    return {
      'success': false,
      'message': 'Something went wrong',
    };
  }
}

/// GET LIVE COPPER RATE
Future<Map<String, dynamic>> getLiveCopperRate() async {
  final Uri url = Uri.parse('$_baseUrl/GetLiveCopperFullRate');

  try {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return {'success': false, 'message': 'Server error: ${response.statusCode}'};
    }

    // Remove XML wrapper
    final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final Map<String, dynamic> data = jsonDecode(cleanJson);
        debugPrint('LiveCopper Rates: $data');

    return {'success': true, 'data': data};
  } catch (e) {
    debugPrint('LiveCopper Error: $e');
    return {'success': false, 'message': 'Something went wrong'};
  }
}

}