import 'package:equatable/equatable.dart';

class VaultNote extends Equatable {
  const VaultNote({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, title, body, updatedAt];
}
