import 'dart:ui';

enum PinKind { idea, progress, completed, urgent, favorite }

class Note {
  const Note({
    required this.id,
    required this.boardId,
    required this.text,
    required this.position,
    required this.color,
    required this.pin,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String boardId;
  final String text;
  final Offset position;
  final Color color;
  final PinKind pin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({String? text, Offset? position, DateTime? updatedAt}) => Note(
        id: id,
        boardId: boardId,
        text: text ?? this.text,
        position: position ?? this.position,
        color: color,
        pin: pin,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
