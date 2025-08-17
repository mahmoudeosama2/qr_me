import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeModel {
  final String id;
  final String text;
  final String type;
  final String? title;
  final String? description;
  final String color;
  final String backgroundColor;
  final int size;
  final DateTime createdAt;
  final int viewCount;
  final String? userId;

  QRCodeModel({
    required this.id,
    required this.text,
    required this.type,
    this.title,
    this.description,
    this.color = '#000000',
    this.backgroundColor = '#FFFFFF',
    this.size = 200,
    required this.createdAt,
    this.viewCount = 0,
    this.userId,
  });

  factory QRCodeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QRCodeModel(
      id: doc.id,
      text: data['text'] ?? '',
      type: data['type'] ?? 'text',
      title: data['title'],
      description: data['description'],
      color: data['color'] ?? '#000000',
      backgroundColor: data['backgroundColor'] ?? '#FFFFFF',
      size: data['size'] ?? 200,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'] ?? 0,
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'type': type,
      'title': title,
      'description': description,
      'color': color,
      'backgroundColor': backgroundColor,
      'size': size,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewCount': viewCount,
      'userId': userId,
    };
  }

  QRCodeModel copyWith({
    String? id,
    String? text,
    String? type,
    String? title,
    String? description,
    String? color,
    String? backgroundColor,
    int? size,
    DateTime? createdAt,
    int? viewCount,
    String? userId,
  }) {
    return QRCodeModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      userId: userId ?? this.userId,
    );
  }
}

enum QRType {
  text,
  url,
  email,
  wifi,
  contact,
}

extension QRTypeExtension on QRType {
  String get name {
    switch (this) {
      case QRType.text:
        return 'text';
      case QRType.url:
        return 'url';
      case QRType.email:
        return 'email';
      case QRType.wifi:
        return 'wifi';
      case QRType.contact:
        return 'contact';
    }
  }

  String get displayName {
    switch (this) {
      case QRType.text:
        return 'Text';
      case QRType.url:
        return 'URL';
      case QRType.email:
        return 'Email';
      case QRType.wifi:
        return 'WiFi';
      case QRType.contact:
        return 'Contact';
    }
  }
}