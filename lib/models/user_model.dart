import 'ticket_request_success.dart';

class UserResponse {
  final int checkedInCount;
  final int totalCount;
  final List<TicketSuccessResponse> results;

  UserResponse({
    required this.checkedInCount,
    required this.totalCount,
    required this.results,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      checkedInCount: json['checkedInCount'] is double ? (json['checkedInCount'] as double).toInt() : json['checkedInCount'] as int,
      totalCount: json['totalCount'] is double ? (json['totalCount'] as double).toInt() : json['totalCount'] as int,
      results: (json['tickets'] as List)
          .map((user) => TicketSuccessResponse.fromJson(user))
          .toList(),
    );
  }
}
