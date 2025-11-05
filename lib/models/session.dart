import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { pending, confirmed, denied }

class Session {
  final String id;
  final String campaignId;
  final DateTime dateTime;
  String description;
  final Map<String, AttendanceStatus> attendance;

  Session({
    required this.id,
    required this.campaignId,
    required this.dateTime,
    this.description = '',
    required this.attendance,
  });

  Map<String, dynamic> toJson() {
    final attendanceAsStrings = attendance.map((key, value) {
      return MapEntry(key, value.name);
    });

    return {
      'campaignId': campaignId,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'attendance': attendanceAsStrings,
    };
  }

  factory Session.fromJson(String id, Map<String, dynamic> json) {
    final attendanceAsStrings = json['attendance'] as Map<String, dynamic>;
    final attendanceAsEnums = attendanceAsStrings.map((key, value) {
      final status = AttendanceStatus.values.firstWhere(
            (e) => e.name == value,
        orElse: () => AttendanceStatus.pending,
      );
      return MapEntry(key, status);
    });

    return Session(
      id: id,
      campaignId: json['campaignId'] as String,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      description: json['description'] as String,
      attendance: attendanceAsEnums,
    );
  }
}