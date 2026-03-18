import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      // 'https://wealthbridgeimpex.com/WebService2.asmx';
      'https://wealthbridgeimpex.com/webservice.asmx';

  /// CLEAN XML RESPONSE
  String _cleanResponse(String body) {
    return body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// CHECK SUCCESS
  bool _isSuccess(Map<String, dynamic> json) {
    final status = json['status'] ?? json['Status'];
    return status?.toString().toLowerCase() == 'success';
  }

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
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final safeLandmark = landmark.trim();
    final safeGST = gst.trim();
    final safeBankName = bankName.trim();
    final safeAccountHolder = accountHolderName.trim();
    final safeAccountNumber = accountNumber.trim();
    final safeIfsc = ifscCode.trim();

    final String queryString =
        'fullname=${Uri.encodeComponent(fullName.trim())}'
        '&email=${Uri.encodeComponent(email.trim())}'
        '&mobile=${Uri.encodeComponent(mobile.trim())}'
        '&password=${Uri.encodeComponent(password.trim())}'
        '&address=${Uri.encodeComponent(address.trim())}'
        '&landmark=${Uri.encodeComponent(safeLandmark)}'
        '&pincode=${Uri.encodeComponent(pincode.trim())}'
        '&gst=${Uri.encodeComponent(safeGST)}'
        '&bank_name=${Uri.encodeComponent(safeBankName)}'
        '&account_holder_name=${Uri.encodeComponent(safeAccountHolder)}'
        '&account_number=${Uri.encodeComponent(safeAccountNumber)}'
        '&ifsc_code=${Uri.encodeComponent(safeIfsc)}';

    final Uri url = Uri.parse('$_baseUrl/RegisterUser?$queryString');

    // debugPrint('Register API URL: $url');

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
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Registered successfully' : 'Registration failed'),
      };
    } catch (e) {
      // debugPrint('Register Error: $e');
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

  /// Update User Profile
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
    //  debugPrint('email or mobile:$emailOrMobile');

    // debugPrint('GetUser API URL: $url');

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
      // debugPrint('GetUser Error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// DELETE USER ACCOUNT (GET)
  Future<Map<String, dynamic>> deleteUserAccount({required int userId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/DeleteUserAccount',
    ).replace(queryParameters: {'id': userId.toString()});

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
        'message':
            jsonData['Message'] ??
            (isSuccess ? 'Account deleted' : 'Delete failed'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET LIVE COPPER RATE
  Future<Map<String, dynamic>> getLiveCopperRate() async {
    final Uri url = Uri.parse('$_baseUrl/GetLiveCopperFullRate');

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

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      //  print('LiveCopper Rates: $data');

      return {'success': true, 'data': data};
    } catch (e) {
      // debugPrint('LiveCopper Error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// ADD TO CART (GET)
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required String slabName,
    required double pricePerKg,
    required int qty,
    required int minWeight,
    required int maxWeight,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/AddToCart').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'slabName': slabName,
        'pricePerKg': pricePerKg.toString(),
        'qty': qty.toString(),
        'minWeight': minWeight.toString(),
        'maxWeight': maxWeight.toString(),
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

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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

  /// GET ORDERS BY USER
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

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      // Decode JSON
      final List<dynamic> jsonData = jsonDecode(cleanJson);
      // print('\ngetOrdersByUser:$jsonData\n');

      return {'success': true, 'data': jsonData};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET ORDER BY ID
  Future<Map<String, dynamic>> getOrderById({required int orderId}) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetOrderByID',
    ).replace(queryParameters: {'id': orderId.toString()});

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

      // Decode JSON
      final List<dynamic> jsonData = jsonDecode(cleanJson);
      // print('\ngetOrderById:$jsonData\n');

      // Usually GetOrderByID returns a list with one object, extract first
      final Map<String, dynamic> orderData = jsonData.isNotEmpty
          ? Map<String, dynamic>.from(jsonData[0])
          : {};

      return {'success': true, 'data': orderData};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  /// GET SHIPMENTS BY USER
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

  /// CHECK IF USER CAN SELL
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

      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      final jsonData = jsonDecode(cleanJson);

      final bool isSuccess = jsonData['Status'] == 'Success';

      return {
        'success': isSuccess,
        'message': jsonData['Message'],
        'remainingQty': jsonData['RemainingQty'],
        'slabId': jsonData['SlabId'],
        'slabName': jsonData['SlabName'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET SELL DETAILS
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

      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      //  print("\nsell details $jsonData--\n");
      final bool isSuccess = jsonData['Status'] == 'Success';

      return {
        'success': isSuccess,
        'message': jsonData['Message'],
        'slabName': jsonData['SlabName'],
        'pricePerKg': jsonData['CurrentSellPrice'],
        'remainingQty': jsonData['RemainingQty'],
        'deliveryOption': jsonData['DeliveryOption'],
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// PLACE SELL ORDER
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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      //  print("\n\n SELL --- $jsonData-- \n\n");

      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message':
            jsonData['Message'] ?? (isSuccess ? 'Sell order placed' : 'Failed'),
        'data': jsonData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// GET BANK DETAILS
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
        return {'success': false, 'message': 'Bank details not found'};
      }

      return {
        'success': true,
        'data': {
          'bankName': jsonData['BankName'],
          'accountHolder': jsonData['AccountHolder'],
          'accountNumber': jsonData['AccountNumber'],
          'ifscCode': jsonData['IfscCode'],
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// SAVE BANK DETAILS
  Future<Map<String, dynamic>> saveBankDetails({
    required int userId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/SaveBankDetails').replace(
      queryParameters: {
        'user_id': userId.toString(),
        'bank_name': bankName.trim(),
        'account_holder_name': accountHolderName.trim(),
        'account_number': accountNumber.trim(),
        'ifsc_code': ifscCode.trim(),
      },
    );

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
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'mobile_no': mobileNo.trim()},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      final cleanJson = _cleanResponse(response.body);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess = _isSuccess(jsonData);
      // print("\n\n forgotPassword $jsonData \n\n");
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
      // print("\n\n API $mobileNo and $otp \n\n");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'mobile_no': mobileNo.trim(), 'otp': otp.trim()},
      );
      // print("\n\n API ${response.statusCode} \n\n");

      // print("\n\n API ${response.body} \n\n");
      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Server error'};
      }

      // remove XML wrapper
      final cleanBody = _cleanResponse(response.body);

      final Map<String, dynamic> jsonData = jsonDecode(cleanBody);

      final status = jsonData['Status'] ?? jsonData['status'];
      final bool isSuccess = status.toString().toLowerCase() == 'success';
      // print("\n\n verifyOtp API $jsonData \n\n");
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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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
      // print("\n\n resetPassword API $jsonData \n\n");
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

  /// GET USER HOLDINGS
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

      final bool isSuccess = jsonData['Status'] == true;

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

  /// GET DELIVERY CHARGES
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

      // Remove XML wrapper
      final cleanJson = response.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      final bool isSuccess =
          jsonData['Status']?.toString().toLowerCase() == 'success';

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
/*



GET
getUserByEmailOrMobile
getLiveCopperRate
getOrdersByUser
getOrderById
getShipments
canUserSell
getSellDetails
getBankDetails

POST
registerUser
loginUser
updateUserProfile
addToCart
placeOrderFromCart
placeSellOrder
saveBankDetails
deleteUserAccount
ForgotPassword
VerifyOTP
ResetPassword
contactus

API Name: GetMyHoldings

Parameters:
user_id : 

{
 "status": true,
 "message": "Holdings fetched successfully",
 "data": [
  {
   "slab_name": "100 KG +",
   "bought_qty": 100,
   "sold_qty": 1,
   "remaining_qty": 99,
   "buy_price_per_kg": 1615.5,
   "current_rate": 1265.5,
   "invested_amount": 161550,
   "current_value": 125284.5,
   "profit_loss": -36265.5
  },
  {
   "slab_name": "50 - 100 KG",
   "bought_qty": 60,
   "sold_qty": 10,
   "remaining_qty": 50,
   "buy_price_per_kg": 1580.0,
   "current_rate": 1265.5,
   "invested_amount": 94800,
   "current_value": 63275,
   "profit_loss": -31525
  }
 ]
}

 No holdings case

{
 "status": true,
 "message": "No holdings found",
 "data": []
}

Error responses

Invalid user
{
 "status": false,
 "message": "Invalid user id"
}

Server issue

{
 "status": false,
 "message": "Something went wrong. Please try again later."
}

Database issue


{
 "status": false,
 "message": "Unable to fetch holdings data"
}

Backend calculation 

remaining_qty = bought_qty - sold_qty
invested_amount = bought_qty * buy_price_per_kg
current_value = remaining_qty * current_rate
profit_loss = current_value - invested_amount

 */