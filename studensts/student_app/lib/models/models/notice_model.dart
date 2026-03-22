class NoticeModel {
  final String? id;
  final String title;
  final String content;
  final String category;
  final String targetType;
  final String? targetClassId;
  final bool isPinned;
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;

  NoticeModel({
    this.id,
    required this.title,
    required this.content,
    this.category = 'general',
    this.targetType = 'all',
    this.targetClassId,
    this.isPinned = false,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    final userData = json['users'];
    return NoticeModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String? ?? 'general',
      targetType: json['target_type'] as String? ?? 'all',
      targetClassId: json['target_class_id'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdByName: userData is Map ? userData['full_name'] as String? : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'target_type': targetType,
      'target_class_id': targetClassId,
      'is_pinned': isPinned,
      'created_by': createdBy,
    };
  }

  String get categoryLabel => category[0].toUpperCase() + category.substring(1);

  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
