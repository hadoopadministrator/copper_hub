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
    required String pincode,
    String? landmark, // optional
    String? gst, // optional
  }) async {
    final Map<String, String> queryParams = {
      'fullname': fullName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'address': address,
      'pincode': pincode,
    };

    if (landmark != null && landmark.isNotEmpty) {
      queryParams['landmark'] = landmark;
    }

    if (gst != null && gst.isNotEmpty) {
      queryParams['gst'] = gst;
    }

    final Uri url = Uri.parse(
      '$_baseUrl/RegisterUser',
    ).replace(queryParameters: queryParams);

    debugPrint('Register API URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        debugPrint('Register Raw Response: ${response.body}');

        // Remove XML wrapper ONLY
        final jsonFormat = response.body
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();

        debugPrint('Register Clean JSON: $jsonFormat');

        final Map<String, dynamic> jsonData = jsonDecode(jsonFormat);

        final String status =
            jsonData['Status']?.toString().toLowerCase() ?? '';

        final String message =
            jsonData['Message']?.toString() ?? 'Registration failed';

        if (status == 'success') {
          return {'success': true, 'message': message};
        } else {
          return {
            'success': false,
            'message': message, // e.g. User Already Exists
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
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
      queryParameters: {'emailOrMobile': emailOrMobile, 'password': password},
    );

    debugPrint('Login API URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Remove XML wrapper
        final cleanText = response.body
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();

        debugPrint('Login Clean JSON: $cleanText');

        final Map<String, dynamic> jsonData = jsonDecode(cleanText);

        final status = jsonData['Status']?.toString().toLowerCase();

        if (status == 'success') {
          return {
            'success': true,
            'message': 'Login successful',
            'data': jsonData,
          };
        }

        // Invalid credentials or failure
        return {
          'success': false,
          'message': jsonData['Message'] ?? 'Invalid login credentials',
        };
      }

      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }
}
