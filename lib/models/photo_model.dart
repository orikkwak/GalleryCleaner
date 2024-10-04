// getlery/lib/models/photo_model.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class Photo {
  final String id;
  final String path;
  final DateTime createdAt;
  final bool isCaptured;
  final String? category;

  Photo({
    required this.id,
    required this.path,
    required this.createdAt,
    required this.isCaptured,
    this.category,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'],
      createdAt: DateTime.parse(json['createdAt']),
      isCaptured: json['isCaptured'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'isCaptured': isCaptured,
      'category': category,
    };
  }
}
