/// Plain data classes mapping the API's JSON responses.

class Posting {
  final int id;
  final String title;
  final String companyName;
  final String description;
  final String requirements;
  final String location;
  final int slots;
  final String? deadline;
  final String status;
  final int applicationCount;

  Posting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.requirements,
    required this.location,
    required this.slots,
    required this.deadline,
    required this.status,
    required this.applicationCount,
  });

  factory Posting.fromJson(Map<String, dynamic> j) => Posting(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        companyName: (j['company_name'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        requirements: (j['requirements'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        slots: (j['slots'] ?? 1) as int,
        deadline: j['deadline'] as String?,
        status: (j['status'] ?? 'pending') as String,
        applicationCount: (j['application_count'] ?? 0) as int,
      );
}

class Application {
  final int id;
  final int posting;
  final String postingTitle;
  final String studentName;
  final String coverLetter;
  final String status;

  Application({
    required this.id,
    required this.posting,
    required this.postingTitle,
    required this.studentName,
    required this.coverLetter,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> j) => Application(
        id: j['id'] as int,
        posting: (j['posting'] ?? 0) as int,
        postingTitle: (j['posting_title'] ?? '') as String,
        studentName: (j['student_name'] ?? '') as String,
        coverLetter: (j['cover_letter'] ?? '') as String,
        status: (j['status'] ?? 'pending') as String,
      );
}

class NotificationItem {
  final int id;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as int,
        message: (j['message'] ?? '') as String,
        isRead: (j['is_read'] ?? false) as bool,
        createdAt: (j['created_at'] ?? '') as String,
      );
}
