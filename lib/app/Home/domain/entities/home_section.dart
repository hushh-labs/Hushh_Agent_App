import 'package:equatable/equatable.dart';

/// Represents a section in the home navigation
class HomeSection extends Equatable {
  final String id;
  final String title;
  final String icon;
  final int index;
  final bool isActive;
  final int? notificationCount;

  const HomeSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.index,
    this.isActive = false,
    this.notificationCount,
  });

  HomeSection copyWith({
    String? id,
    String? title,
    String? icon,
    int? index,
    bool? isActive,
    int? notificationCount,
  }) {
    return HomeSection(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      isActive: isActive ?? this.isActive,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }

  @override
  List<Object?> get props => [id, title, icon, index, isActive, notificationCount];
}

/// Predefined home sections
class HomeSections {
  static const List<HomeSection> defaultSections = [
    HomeSection(
      id: 'dashboard',
      title: 'Home',
      icon: 'dashboard',
      index: 0,
    ),
    HomeSection(
      id: 'chat',
      title: 'Messages',
      icon: 'chat',
      index: 1,
    ),
    HomeSection(
      id: 'profile',
      title: 'Profile',
      icon: 'profile',
      index: 2,
    ),
  ];
} 