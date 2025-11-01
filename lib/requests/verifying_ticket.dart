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
          "verifyMyTicket Response data ${response.data} data null: ${response.data == null} ");

      debugPrint(
          "verifyMyTicket Response data status code: ${response.statusCode}}");
      if (response.data == null || response.data.toString().isEmpty) {
        return null;
      }
      Map<String, dynamic> responseData = response.data;
      bool success = responseData['success'] ?? false;
      bool hasSuccessKey = responseData.containsKey('success');
      debugPrint("Success $success ${response.statusCode}");
      if (response.statusCode == 200) {
        debugPrint("Has Success key $hasSuccessKey");
        if (!hasSuccessKey) {
          return ErrSuccResponse(
              success: true,
              ticketSuccess: TicketSuccessResponse.fromJson(response.data),
              error: null);
        } else {
          if (success) {
            return ErrSuccResponse(
                success: true,
                ticketSuccess: TicketSuccessResponse.fromJson(response.data),
                error: null);
          } else {
            // If success is false, check the message for specific errors like "Ticket is used up"
            String? message = responseData['message'];

            return ErrSuccResponse(
              success: false,
              error: TicketErrorResponse(
                  message: message!.isNotEmpty
                      ? message
                      : "An unknown error occurred.Try again."),
            );
          }
        }
      } else {
        return ErrSuccResponse(
          success: false,
          error: TicketErrorResponse.fromJson(response.data),
        );
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
    Response response = await dio.get(
      Urls.getAllTickets,
    );
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
    try {
      Response response = await dio.get(
        Urls.getAllUsers,
      );
      print(response.realUri);
      print(response.data.toString());
      print(
          "getAllUsers Response data ${response.data} Status code: ${response.statusCode} data null: ${response.data == null} ");

      if (response.data == null || response.data.toString().isEmpty) {
        return null;
      }

      if (response.statusCode == 200) {
        debugPrint("@@ getAllUsers ${response.data}");
        // List data = response.data['tickets'];

        // List<TicketSuccessResponse> allItems = data
        //     .map((element) => TicketSuccessResponse.fromJson(element))
        //     .toList();

        // return allItems;
        return UserResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching all users ${e.toString()}");
      return null;
    }
  }
}
