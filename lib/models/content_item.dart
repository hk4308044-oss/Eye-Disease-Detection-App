import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories of admin-managed content
enum ContentCategory {
  education,
  screeningInfo,
  recommendations,
  faq,
  announcement,
  specialization,
  clinic;

  String get label {
    switch (this) {
      case ContentCategory.education:
        return 'Educational Content';
      case ContentCategory.screeningInfo:
        return 'Screening Info';
      case ContentCategory.recommendations:
        return 'Health Recommendations';
      case ContentCategory.faq:
        return 'FAQ';
      case ContentCategory.announcement:
        return 'System Announcement';
      case ContentCategory.specialization:
        return 'Specialization';
      case ContentCategory.clinic:
        return 'Clinic Directory';
    }
  }

  static ContentCategory fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'education':
        return ContentCategory.education;
      case 'screeninginfo':
        return ContentCategory.screeningInfo;
      case 'recommendations':
        return ContentCategory.recommendations;
      case 'faq':
        return ContentCategory.faq;
      case 'announcement':
        return ContentCategory.announcement;
      case 'specialization':
        return ContentCategory.specialization;
      case 'clinic':
        return ContentCategory.clinic;
      default:
        return ContentCategory.education;
    }
  }
}

/// Admin-managed content & configuration document stored in Firestore `content_items/{id}`
class ContentItem {
  final String id;
  final ContentCategory category;
  final String title;
  final String content;
  final String? subtitle;
  final String? iconName;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorName;

  ContentItem({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    this.subtitle,
    this.iconName,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
    this.authorName = 'Admin',
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'title': title,
      'content': content,
      'subtitle': subtitle,
      'iconName': iconName,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'authorName': authorName,
    };
  }

  factory ContentItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ContentItem(
      id: doc.id,
      category: ContentCategory.fromString(data['category']),
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      subtitle: data['subtitle'],
      iconName: data['iconName'],
      isPublished: data['isPublished'] ?? true,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      authorName: data['authorName'] ?? 'Admin',
    );
  }

  ContentItem copyWith({
    ContentCategory? category,
    String? title,
    String? content,
    String? subtitle,
    String? iconName,
    bool? isPublished,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      subtitle: subtitle ?? this.subtitle,
      iconName: iconName ?? this.iconName,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      authorName: authorName,
    );
  }
}
