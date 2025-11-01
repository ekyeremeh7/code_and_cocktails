import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class ApiException implements Exception {
  ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      // case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioException.response?.statusCode,
          dioException.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (dioException.message!.contains("SocketException")) {
          message = 'No Internet';
          break;
        }

        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  late String message;

  @override
  String toString() => message;

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return error['error'];
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops... something went wrong';
    }
  }
}

String handleError(DioException e) {
  if (e.response != null && e.response!.data != null) {
    final responseData = e.response!.data;
    final message = responseData['message'] ?? 'An unexpected error occurred';
    final statusCode = e.response!.statusCode;

    debugPrint("Response $message  ${e.error}");

    switch (statusCode) {
      case 500:
      case 502:
      case 503:
      case 403:
      case 404:
      case 400:
        // return ErrSuccResponse(
        //   success: false,
        //   error: TicketErrorResponse(message: message.toString()),
        // );
        return message;
      default:
        // return ErrSuccResponse(
        //   success: false,
        //   error: TicketErrorResponse(message: "Unexpected error"),
        // );
        return "Unexpected error";
    }
  } else {
    String message = '';
    debugPrint("Type ${e.type}");

    switch (e.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.badCertificate:
        message = "Invalid Certificate";
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Please verify that your internet connection is stable and active, then try performing the action again';
        break;
      case DioExceptionType.badResponse:
        message = 'An error occurred. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (e.error.toString().contains("SocketException")) {
          message =
              'Verify that your internet connection is stable and active, then try performing the action again';
          break;
        }
        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
    debugPrint("Error message $message");
    return message;
    // return ErrSuccResponse(
    //   success: false,
    //   error: TicketErrorResponse(message: message.toString()),
    // );
  }
}
