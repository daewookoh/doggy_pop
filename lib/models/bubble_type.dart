import 'dart:math';
import 'package:flutter/material.dart';

enum BubbleType {
  red,
  green,
  blue,
  yellow,
  purple,
  orange,
}

extension BubbleTypeExtension on BubbleType {
  // Pastel bubble colors (outer bubble)
  Color get color {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFFFB5C5); // Pastel pink
      case BubbleType.green:
        return const Color(0xFFB5F5C5); // Pastel mint
      case BubbleType.blue:
        return const Color(0xFFB5E5FF); // Pastel sky blue
      case BubbleType.yellow:
        return const Color(0xFFFFE5A5); // Pastel yellow
      case BubbleType.purple:
        return const Color(0xFFE5C5FF); // Pastel lavender
      case BubbleType.orange:
        return const Color(0xFFFFD5B5); // Pastel peach
    }
  }

  Color get darkColor {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFFF9AAE); // Darker pastel pink
      case BubbleType.green:
        return const Color(0xFF8CE5A5); // Darker pastel mint
      case BubbleType.blue:
        return const Color(0xFF8ACFFF); // Darker pastel blue
      case BubbleType.yellow:
        return const Color(0xFFFFD580); // Darker pastel yellow
      case BubbleType.purple:
        return const Color(0xFFD5A5FF); // Darker pastel lavender
      case BubbleType.orange:
        return const Color(0xFFFFBF8A); // Darker pastel peach
    }
  }

  // Paw pad colors (inside the bubble)
  Color get pawColor {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFFF8FA5); // Pink paw
      case BubbleType.green:
        return const Color(0xFF7CE595); // Green paw
      case BubbleType.blue:
        return const Color(0xFF7AC5F5); // Blue paw
      case BubbleType.yellow:
        return const Color(0xFFFFC560); // Yellow paw
      case BubbleType.purple:
        return const Color(0xFFD595FF); // Purple paw
      case BubbleType.orange:
        return const Color(0xFFFFAF6A); // Orange paw
    }
  }

  Color get pawDarkColor {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFE57085); // Darker pink paw
      case BubbleType.green:
        return const Color(0xFF5CC575); // Darker green paw
      case BubbleType.blue:
        return const Color(0xFF5AA5D5); // Darker blue paw
      case BubbleType.yellow:
        return const Color(0xFFE5A540); // Darker yellow paw
      case BubbleType.purple:
        return const Color(0xFFB575E5); // Darker purple paw
      case BubbleType.orange:
        return const Color(0xFFE58F4A); // Darker orange paw
    }
  }

  String get emoji {
    switch (this) {
      case BubbleType.red:
        return '🔴';
      case BubbleType.green:
        return '🟢';
      case BubbleType.blue:
        return '🔵';
      case BubbleType.yellow:
        return '🟡';
      case BubbleType.purple:
        return '🟣';
      case BubbleType.orange:
        return '🟠';
    }
  }

  static BubbleType random([int maxTypes = 4]) {
    final types = BubbleType.values.take(maxTypes).toList();
    return types[Random().nextInt(types.length)];
  }

  static BubbleType randomFrom(List<BubbleType> types) {
    if (types.isEmpty) return BubbleType.red;
    return types[Random().nextInt(types.length)];
  }
}
