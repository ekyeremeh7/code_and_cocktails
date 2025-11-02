import 'package:flutter_dotenv/flutter_dotenv.dart';

class TicketsUrls {
  static String get verifyMyTicket => dotenv.get('VERIFY_TICKET_URL');
  static String get getAllTickets => dotenv.get('GET_ALL_TICKETS_URL');
  static String get getAllUsers => dotenv.get('GET_ALL_USERS_URL');
}
