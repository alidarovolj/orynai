class Notification {
  final int id;
  final String serviceName;
  final String channel;
  final String priority;
  final String status;
  final NotificationRecipient recipient;
  final String targetRole;
  final String subject;
  final String content;
  final Map<String, dynamic> data;
  final String providerId;
  final String sentAt;
  final int retryCount;
  final int maxRetries;
  final String createdAt;
  final String updatedAt;
  final bool isRead;

  Notification({
    required this.id,
    required this.serviceName,
    required this.channel,
    required this.priority,
    required this.status,
    required this.recipient,
    required this.targetRole,
    required this.subject,
    required this.content,
    required this.data,
    required this.providerId,
    required this.sentAt,
    required this.retryCount,
    required this.maxRetries,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      serviceName: json['service_name'] as String,
      channel: json['channel'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      recipient: NotificationRecipient.fromJson(
        json['recipient'] as Map<String, dynamic>,
      ),
      targetRole: json['target_role'] as String,
      subject: json['subject'] as String,
      content: json['content'] as String,
      data: json['data'] as Map<String, dynamic>,
      providerId: json['provider_id'] as String,
      sentAt: json['sent_at'] as String,
      retryCount: json['retry_count'] as int,
      maxRetries: json['max_retries'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      isRead: json['is_read'] as bool,
    );
  }
}

class NotificationRecipient {
  final String phone;
  final String userId;

  NotificationRecipient({
    required this.phone,
    required this.userId,
  });

  factory NotificationRecipient.fromJson(Map<String, dynamic> json) {
    return NotificationRecipient(
      phone: json['phone'] as String,
      userId: json['user_id'] as String,
    );
  }
}

class NotificationsResponse {
  final int limit;
  final List<Notification> notifications;
  final int offset;
  final int total;

  NotificationsResponse({
    required this.limit,
    required this.notifications,
    required this.offset,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      limit: json['limit'] as int,
      notifications: (json['notifications'] as List)
          .map((item) => Notification.fromJson(item as Map<String, dynamic>))
          .toList(),
      offset: json['offset'] as int,
      total: json['total'] as int,
    );
  }
}
