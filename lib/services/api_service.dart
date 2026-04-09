import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://wealthbridgeimpex.com/webservice.asmx';

  // 'https://wealthbridgeimpex.com/WebService2.asmx'; test url

  /// COMMON HEADERS
  static const _headers = {'Content-Type': 'application/x-www-form-urlencoded'};

  /// CLEAN XML RESPONSE
  String _cleanResponse(String body) {
    return body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// CHECK SUCCESS
  bool _isSuccess(Map<String, dynamic> json) {
    final status = json['status'] ?? json['Status'];
    return status?.toString().toLowerCase() == 'success';
  }

  /// REGISTER USER (POST)
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String address,
    required String landmark,
    required String pincode,
    required String gst,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/RegisterUser');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'fullname': fullName.trim(),
          'email': email.trim(),
          'mobile': mobile.trim(),
          'password': password.trim(),
          'address': address.trim(),
          'landmark': landmark.trim(),
          'pincode': pincode.trim(),
          'gst': gst.trim(),
          'bank_name': bankName.trim(),
          'account_holder_name': accountHolderName.trim(),
          'account_number': accountNumber.trim(),
          'ifsc_code': ifscCode.trim(),
        },
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Registered successfully' : 'Registration failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// LOGIN USER (POST)
  Future<Map<String, dynamic>> loginUser({
    required String emailOrMobile,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/LoginUser');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'emailOrMobile': emailOrMobile.trim(),
          'password': password.trim(),
        },
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Login successful' : 'Login failed'),
        'data': jsonData,
        'userId': jsonData['Id'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// Update User Profile (POST)
  Future<Map<String, dynamic>> updateUserProfile({
    required int id,
    required String fullname,
    required String email,
    required String mobile,
    required String address,
    required String landmark,
    required String pincode,
    required String gst,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/UpdateUserProfile');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'id': id.toString(),
          'fullname': fullname,
          'email': email,
          'mobile': mobile,
          'address': address,
          'landmark': landmark,
          'pincode': pincode,
          'gst': gst,
          'bank_name': bankName,
          'account_holder': accountHolder,
          'account_number': accountNumber,
          'ifsc_code': ifscCode,
        },
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);

      if (cleanJson.isEmpty) {
        return {'success': false, 'message': 'Invalid response'};
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Profile updated' : 'Update failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET USER BY EMAIL OR MOBILE (GET)
  Future<Map<String, dynamic>> getUserByEmailOrMobile({
    required String emailOrMobile,
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetUserByEmailOrMobile',
    ).replace(queryParameters: {'value': emailOrMobile.trim()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message': jsonData['Message'],
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// DELETE USER ACCOUNT (POST)
  Future<Map<String, dynamic>> deleteUserAccount({required int userId}) async {
    final Uri url = Uri.parse('$_baseUrl/DeleteUserAccount');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {'id': userId.toString()},
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Account deleted' : 'Delete failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET LIVE COPPER RATE (GET)
  Future<Map<String, dynamic>> getLiveCopperRate() async {
    final Uri url = Uri.parse('$_baseUrl/GetLiveCopperFullRate');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      return {'success': true, 'data': jsonData};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// ADD TO CART (POST)
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int slabId,
    required String slabName,
    required double pricePerKg,
    required int qty,
    required double minWeight,
    required double maxWeight,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/AddToCart');

    try {
      final body = {
        'user_id': userId.toString(),
        'slab_id': slabId.toString(),
        'slabName': slabName,
        'pricePerKg': pricePerKg.toString(),
        'qty': qty.toString(),
        'minWeight': minWeight.toString(),
        'maxWeight': maxWeight.toString(),
      };

      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Added to cart' : 'Failed to add to cart'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET CART (GET)
  Future<Map<String, dynamic>> getCart({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetCart',
    ).replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);

      if (cleanJson.isEmpty) {
        return {'success': false, 'message': 'Empty response'};
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      if (!isSuccess) {
        return {
          'success': false,
          'message': jsonData['Message'] ?? 'Failed to fetch cart',
        };
      }

      final List<dynamic> cartList = jsonData['Data'] ?? [];
      final double totalWeight = (jsonData['TotalWeight'] ?? 0).toDouble();
      final double grandTotal = (jsonData['GrandTotal'] ?? 0).toDouble();

      return {
        'success': true,
        'message': jsonData['Message'],
        'data': cartList,
        'totalWeight': totalWeight,
        'grandTotal': grandTotal,
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// UPDATE CART QTY (POST)
  Future<Map<String, dynamic>> updateCartQty({
    required int userId,
    required int slabId,
    required int qty,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/UpdateCartQty');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'user_id': userId.toString(),
          'slab_id': slabId.toString(),
          'qty': qty.toString(),
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Cart updated' : 'Update failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// REMOVE CART ITEM (POST)
  Future<Map<String, dynamic>> removeCartItem({
    required int userId,
    required int slabId,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/RemoveFromCart');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {'user_id': userId.toString(), 'slab_id': slabId.toString()},
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Item removed' : 'Remove failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// PLACE ORDER FROM CART (POST)
  Future<Map<String, dynamic>> placeOrderFromCart({
    required int userId,
    required String razorpayPaymentId,
    required String deliveryOption,
    String? gst,
    String? courier,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/PlaceOrderFromCart');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'user_id': userId.toString(),
          'razorpay_payment_id': razorpayPaymentId,
          'delivery_option': deliveryOption,
          'gst': gst ?? '',
          'courier': courier ?? '',
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ?? (isSuccess ? 'Order placed' : 'Failed'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET ORDERS BY USER (GET)
  Future<Map<String, dynamic>> getOrdersByUser({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetOrdersByUser',
    ).replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      if (!_isSuccess(jsonData)) {
        return {
          'success': false,
          'message': jsonData['Message'] ?? 'Failed to fetch orders',
        };
      }

      final List<dynamic> orders = jsonData['Data'] ?? [];

      return {'success': true, 'data': orders};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET ORDER BY ID (GET)
  Future<Map<String, dynamic>> getOrderById({required int orderId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetOrderByID',
    ).replace(queryParameters: {'orderId': orderId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      if (!_isSuccess(jsonData)) {
        return {
          'success': false,
          'message': jsonData['Message'] ?? 'Failed to fetch order',
        };
      }

      final Map<String, dynamic> orderData = Map<String, dynamic>.from(
        jsonData['Data'] ?? {},
      );

      return {'success': true, 'data': orderData};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET SHIPMENTS BY USER (GET)
  Future<Map<String, dynamic>> getShipments({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetShipments',
    ).replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      // Decode JSON list
      final List<dynamic> jsonData = jsonDecode(cleanJson);

      // Convert to List<Map<String, dynamic>>
      final shipments = List<Map<String, dynamic>>.from(jsonData);

      return {'success': true, 'data': shipments};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// CHECK IF USER CAN SELL (GET)
  Future<Map<String, dynamic>> canUserSell({
    required int userId,
    required int slabId,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/CanUserSell').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'slab_id': slabId.toString(),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final jsonData = jsonDecode(cleanJson);
      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message': jsonData['Message'] ?? '',
        'remainingQty': int.tryParse(jsonData['RemainingQty'].toString()) ?? 0,
        'slabId': jsonData['SlabId'],
        'slabName': jsonData['SlabName'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET SELL DETAILS (GET)
  Future<Map<String, dynamic>> getSellDetails({
    required int userId,
    required int slabId,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/GetSellDetails').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'slab_id': slabId.toString(),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);

      if (cleanJson.isEmpty) {
        return {'success': false, 'message': 'Empty response'};
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'slabName': jsonData['SlabName'] ?? '',
        'pricePerKg':
            double.tryParse(jsonData['CurrentSellPrice'].toString()) ?? 0,
        'remainingQty': int.tryParse(jsonData['RemainingQty'].toString()) ?? 0,
        'deliveryOption': jsonData['DeliveryOption']?.toString().trim() ?? '',
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// PLACE SELL ORDER (POST)
  Future<Map<String, dynamic>> placeSellOrder({
    required int userId,
    required int slabId,
    required int qty,
    required String deliveryOption,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/PlaceSellOrder');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'user_id': userId.toString(),
          'slab_id': slabId.toString(),
          'qty': qty.toString(),
          'delivery_option': deliveryOption,
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ?? (isSuccess ? 'Sell order placed' : 'Failed'),
        'data': jsonData['Data'] ?? {},
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET BANK DETAILS (GET)
  Future<Map<String, dynamic>> getBankDetails({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetBankDetails',
    ).replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);

      if (cleanJson.isEmpty) {
        return {'success': false, 'message': 'No bank data'};
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      if (!isSuccess) {
        return {
          'success': false,
          'message': jsonData['Message'] ?? 'Bank details not found',
        };
      }

      return {
        'success': true,
        'message': jsonData['Message'],
        'data': {
          'bankName': jsonData['BankName'] ?? '',
          'accountHolder': jsonData['AccountHolder'] ?? '',
          'accountNumber': jsonData['AccountNumber'] ?? '',
          'ifscCode': jsonData['IfscCode'] ?? '',
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// SAVE BANK DETAILS (POST)
  Future<Map<String, dynamic>> saveBankDetails({
    required int userId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/SaveBankDetails');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'user_id': userId.toString(),
          'bank_name': bankName.trim(),
          'account_holder_name': accountHolderName.trim(),
          'account_number': accountNumber.trim(),
          'ifsc_code': ifscCode.trim(),
        },
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Bank details saved' : 'Failed to save bank details'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// FORGOT PASSWORD (POST)
  Future<Map<String, dynamic>> forgotPassword({
    required String mobileNo,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/ForgotPassword');

    try {
      final response = await http
          .post(url, headers: _headers, body: {'mobile_no': mobileNo.trim()})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);
      return {
        'success': isSuccess,
        'message': jsonData['Message'],
        'mobile': jsonData['Mobile'] ?? '',
        'otp': jsonData['Otp'] ?? '',
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// VERIFY OTP (POST)
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNo,
    required String otp,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/VerifyOtp');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {'mobile_no': mobileNo.trim(), 'otp': otp.trim()},
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      // remove XML wrapper
      final cleanBody = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanBody);

      final status = jsonData['Status'] ?? jsonData['status'];
      final bool isSuccess = status.toString().toLowerCase() == 'success';
      return {
        'success': isSuccess,
        'message': "${jsonData['Message']}",
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// RESET PASSWORD (POST)
  Future<Map<String, dynamic>> resetPassword({
    required String newPassword,
    required String mobileNo,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/ResetPassword');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'new_password': newPassword.trim(),
          'mobile_no': mobileNo.trim(),
        },
      );

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      // remove XML wrapper
      final cleanBody = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanBody);

      final status = jsonData['Status'] ?? jsonData['status'];
      final bool isSuccess = status.toString().toLowerCase() == 'success';
      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Password updated successfully' : 'Failed'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET USER HOLDINGS (GET)
  Future<Map<String, dynamic>> getUserHoldings({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetMyHoldings',
    ).replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      // Remove XML wrapper
      final cleanJson = _cleanResponse(response.body);

      if (cleanJson.isEmpty) {
        return {'success': false, 'message': 'No holdings found'};
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Holdings fetched' : 'No holdings'),
        'data': jsonData['Data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET DELIVERY CHARGES (GET)
  Future<Map<String, dynamic>> getDeliveryCharges({
    required int userId,
    required double weight,
    required String deliveryOption,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/getDeliveryCharges').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'weight': weight.toString(),
        'delivery_option': deliveryOption,
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      final bool isSuccess = _isSuccess(jsonData);

      return {
        'success': isSuccess,
        'deliveryCharge': jsonData['Delivery_charge'] ?? 0,
        'estimatedDays': jsonData['Estimated_days'] ?? 0,
        'message': jsonData['Message'] ?? (isSuccess ? 'Success' : 'Failed'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
}
