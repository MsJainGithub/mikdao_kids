class SessionModel {
  final int status;
  final String currentSession;
  final List<SessionData> data;

  SessionModel({
    required this.status,
    required this.currentSession,
    required this.data,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      status: json["status"],
      currentSession: json["current_session"].toString(),
      data: (json["data"] as List)
          .map((e) => SessionData.fromJson(e))
          .toList(),
    );
  }
}

class SessionData {
  final String id;
  final String schoolYear;

  SessionData({
    required this.id,
    required this.schoolYear,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json["id"].toString(),
      schoolYear: json["school_year"].toString(),
    );
  }
}