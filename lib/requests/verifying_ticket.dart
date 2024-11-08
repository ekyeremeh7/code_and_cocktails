import 'package:code_and_cocktails/models/ticket_request_error.dart';
import 'package:code_and_cocktails/models/ticket_request_success.dart';
import 'package:code_and_cocktails/requests/urls.dart';
import 'package:code_and_cocktails/shared/services/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/err_success_model.dart';
import '../models/user_model.dart';

class VerifyingTicketSingleton {
  final dio = Dio();

  // Private constructor
  VerifyingTicketSingleton._();

  // Singleton instance
  static final VerifyingTicketSingleton _instance =
      VerifyingTicketSingleton._();

  // Variable and setter
  String _myVariable = '';

  set myVariable(String value) {
    _myVariable = value;
  }

  // Getter
  String get myVariable {
    return _myVariable;
  }

  // Factory constructor to access the singleton instance
  factory VerifyingTicketSingleton() {
    return _instance;
  }

  Future<ErrSuccResponse?> verifyMyTicket({String ticketID = ""}) async {
    try {
      print("ID: ${ticketID.split("/").last}");
      ticketID = ticketID.split("/").last;
      Response response = await dio.get(Urls.verifyMyTicket + ticketID);
      print(response.realUri);
      print(response.data.toString());
      print(
          "Response data ${response.data} Status code: ${response.statusCode} data null: ${response.data == null} ");

      if (response.data == null || response.data.toString().isEmpty) {
        return null;
      }
      Map<String, dynamic> responseData = response.data;
      bool success = responseData['success'] ?? false;

      if (success) {
        return ErrSuccResponse(
            success: true,
            ticketSuccess: TicketSuccessResponse.fromJson(response.data),
            error: null);
      } else {
        // If success is false, check the message for specific errors like "Ticket is used up"
        String? message = responseData['message'];
        if (message == "Ticket is used up") {
          return ErrSuccResponse(
            success: false,
            error: TicketErrorResponse(message: message),
          );
        } else {
          return ErrSuccResponse(
            success: false,
            error: TicketErrorResponse(message: "An unknown error occurred."),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint("Err ${e.toString()}");
      final message = handleError(e);
      debugPrint("Err msg $message");
      return ErrSuccResponse(
        success: false,
        error: TicketErrorResponse(message: message),
      );
    }
    // if (response.statusCode == 200) {
    //   return ErrSuccResponse(
    //       success: TicketSuccessResponse.fromJson(response.data), error: null);
    // } else {
    //   return ErrSuccResponse(
    //     success: null,
    //     error: TicketErrorResponse.fromJson(response.data),
    //   );
    // }
  }

  Future<List<TicketSuccessResponse>?> getAllTickets() async {
    Response response = await dio.get(Urls.getAllTickets);
    print(response.realUri);
    print(response.data.toString());
    print(
        "Response data ${response.data} Status code: ${response.statusCode} data null: ${response.data == null} ");

    if (response.data == null || response.data.toString().isEmpty) {
      return null;
    }

    if (response.statusCode == 200) {
      List data = response.data;

      List<TicketSuccessResponse> allItems = data
          .map((element) => TicketSuccessResponse.fromJson(element))
          .toList();

      return allItems;
    } else {
      return null;
    }
  }



  Future<UserResponse?> getAllUsers() async {
    Response response = await dio.get(Urls.getAllUsers);
    print(response.realUri);
    print(response.data.toString());
    print(
        "getAllUsers Response data ${response.data} Status code: ${response.statusCode} data null: ${response.data == null} ");

    if (response.data == null || response.data.toString().isEmpty) {
      return null;
    }

    if (response.statusCode == 200) {
      debugPrint("getAllUsers ${response.data}");
      // List data = response.data['tickets'];

      // List<TicketSuccessResponse> allItems = data
      //     .map((element) => TicketSuccessResponse.fromJson(element))
      //     .toList();

      // return allItems;
      return UserResponse.fromJson(response.data);
    } else {
      return null;
    }
  }


}

// void main() {
//   // Access the singleton instance
//   VerifyingTicketSingleton singleton = VerifyingTicketSingleton();

//   // Set and get the variable
//   singleton.myVariable = 'Hello, Singleton!';
//   print(singleton.myVariable); // Output: Hello, Singleton!
// }

