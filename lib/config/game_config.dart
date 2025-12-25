import 'package:flutter/material.dart';

class GameConfig {
  // Screen
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  // Bubble
  static const double bubbleRadius = 20.0;
  static const double bubbleDiameter = bubbleRadius * 2;
  static const double bubbleSpeed = 800.0;

  // Grid
  static const int gridColumns = 9;
  static const int maxGridRows = 12;
  static const double gridOffsetY = 60.0; // Base offset (SafeArea padding will be added)
  static const double gridOffsetX = 0.0; // Additional X offset for centering adjustment

  // Hexagonal grid spacing
  static const double rowHeight = bubbleRadius * 1.73; // sqrt(3) for hex grid

  // Shooter
  static const double shooterY = 700.0;

  // Game Rules
  static const int minMatchCount = 3;
  static const int defaultBubbleCount = 30;

  // Scoring
  static const int scorePerPop = 10;
  static const int scorePerDrop = 20;
  static const double combo4Multiplier = 1.5;
  static const double combo5Multiplier = 2.0;

  // Star thresholds (percentage of max possible score)
  static const double star1Threshold = 0.3;
  static const double star2Threshold = 0.6;
  static const double star3Threshold = 0.85;

  // Physics
  static const double gravity = 980.0;

  // Animation durations (milliseconds)
  static const int popAnimationDuration = 200;
  static const int dropAnimationDuration = 500;

  // Colors - Pastel Sky Theme
  static const Color backgroundColor = Color(0xFFE8F4FC); // Light sky blue
  static const Color gridLineColor = Color(0x22000000);
}
