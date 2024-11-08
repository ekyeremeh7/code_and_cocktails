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
      checkedInCount: json['checkedInCount'],
      totalCount: json['totalCount'],
      results: (json['tickets'] as List)
          .map((user) => TicketSuccessResponse.fromJson(user))
          .toList(),
    );
  }
}
