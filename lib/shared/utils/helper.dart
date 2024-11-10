import '../../models/ticket_request_success.dart';

class Helper {
  static bool isServerDataUpdated(List<TicketSuccessResponse> serverData,
      List<TicketSuccessResponse> cachedData) {
    // If the lengths are different, data is updated
    if (serverData.length != cachedData.length) {
      return true;
    }

    // If lengths are the same, compare the checksums of individual items
    for (int i = 0; i < serverData.length; i++) {
      final serverDataCheckSum = generateChecksum(serverData[i]);
      final cachedDataChecksum = generateChecksum(cachedData[i]);
      if (serverDataCheckSum != cachedDataChecksum) {
        return true; // Data is updated if the checksum differs
      }
    }

    // No difference found
    return false;
  }

  static String generateChecksum(TicketSuccessResponse ticket) {
    return '${ticket.sId}-${ticket.squadLimit}-${ticket.qrCodeBase64}-${ticket.updatedAt}';
  }

  static bool isGreaterThan(num value, num other) {
    return value > other;
  }
}
