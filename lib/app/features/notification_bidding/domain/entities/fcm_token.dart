import 'package:equatable/equatable.dart';

class FcmToken extends Equatable {
  final String id;
  final String userId;
  final String token;
  final String platform; // 'ios' or 'android'
  final DateTime createdAt;
  final DateTime updatedAt;

  const FcmToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        token,
        platform,
        createdAt,
        updatedAt,
      ];
}
