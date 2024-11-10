import 'dart:convert';
import 'package:crypto/crypto.dart';

class Ticket {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Ticket object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a Ticket from JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to generate a checksum (hash) for the Ticket
  String generateChecksum() {
    final jsonString = json.encode(toJson()); // Convert ticket to JSON string
    final bytes = utf8.encode(jsonString); // Convert string to bytes
    final digest = sha256.convert(bytes); // Generate SHA-256 hash
    return digest.toString(); // Return the checksum as a string
  }

  // Override equality operator to compare Tickets
  @override
  bool operator ==(Object other) {
    if (other is Ticket) {
      return id == other.id && title == other.title && description == other.description;
    }
    return false;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ description.hashCode;
  }
}

void main() {
  // Example usage
  Ticket ticket1 = Ticket(
    id: '123',
    title: 'Issue with login',
    description: 'User cannot log in to the app',
    status: 'open',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Ticket ticket2 = Ticket(
    id: '123',
    title: 'Issue with login',
    description: 'User cannot log in to the app',
    status: 'open',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  print('Ticket 1 Checksum: ${ticket1.generateChecksum()}');
  print('Ticket 2 Checksum: ${ticket2.generateChecksum()}');
  
  print('Are the tickets equal? ${ticket1 == ticket2}');
}
