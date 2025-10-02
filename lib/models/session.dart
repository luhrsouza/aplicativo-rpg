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
}