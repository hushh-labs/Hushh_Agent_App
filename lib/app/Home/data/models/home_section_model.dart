import '../../domain/entities/home_section.dart';

/// Data model for HomeSection
class HomeSectionModel extends HomeSection {
  const HomeSectionModel({
    required super.id,
    required super.title,
    required super.icon,
    required super.index,
    super.isActive = false,
    super.notificationCount,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      index: json['index'] as int,
      isActive: json['isActive'] as bool? ?? false,
      notificationCount: json['notificationCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'index': index,
      'isActive': isActive,
      'notificationCount': notificationCount,
    };
  }

  factory HomeSectionModel.fromEntity(HomeSection entity) {
    return HomeSectionModel(
      id: entity.id,
      title: entity.title,
      icon: entity.icon,
      index: entity.index,
      isActive: entity.isActive,
      notificationCount: entity.notificationCount,
    );
  }

  HomeSectionModel copyWith({
    String? id,
    String? title,
    String? icon,
    int? index,
    bool? isActive,
    int? notificationCount,
  }) {
    return HomeSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      isActive: isActive ?? this.isActive,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }
} 