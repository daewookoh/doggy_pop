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
  Color get color {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFE74C3C);
      case BubbleType.green:
        return const Color(0xFF2ECC71);
      case BubbleType.blue:
        return const Color(0xFF3498DB);
      case BubbleType.yellow:
        return const Color(0xFFF1C40F);
      case BubbleType.purple:
        return const Color(0xFF9B59B6);
      case BubbleType.orange:
        return const Color(0xFFE67E22);
    }
  }

  Color get darkColor {
    switch (this) {
      case BubbleType.red:
        return const Color(0xFFC0392B);
      case BubbleType.green:
        return const Color(0xFF27AE60);
      case BubbleType.blue:
        return const Color(0xFF2980B9);
      case BubbleType.yellow:
        return const Color(0xFFD4AC0D);
      case BubbleType.purple:
        return const Color(0xFF8E44AD);
      case BubbleType.orange:
        return const Color(0xFFD35400);
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
