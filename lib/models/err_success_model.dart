import 'ticket_request_error.dart';
import 'ticket_request_success.dart';

class ErrSuccResponse {
  bool success;
  TicketSuccessResponse? ticketSuccess;
  TicketErrorResponse? error;

  ErrSuccResponse({required this.success, this.ticketSuccess, this.error});

  // ErrSuccResponse.fromJson(Map<String, dynamic> json) {
  //   success = json['success'];
  //   error = json['message'];
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data =  Map<String, dynamic>();
  //   data['success'] = success;
  //   data['message'] = error;
  //   return data;
  // }

  factory ErrSuccResponse.fromJson(Map<String, dynamic> json) {
    bool success = json['success'] ?? false;
    if (success) {
      return ErrSuccResponse(
        success: true,
        ticketSuccess: TicketSuccessResponse.fromJson(json),
      );
    } else {
      return ErrSuccResponse(
        success: false,
        error: TicketErrorResponse(message: json['message']),
      );
    }
  }
}
