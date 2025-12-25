import 'package:flame/components.dart';
import '../config/game_config.dart';

class HexGridUtils {
  // SafeArea top padding (set from game screen)
  static double safeAreaTop = 0.0;
  // Shooter Y position (calculated based on game area height)
  static double shooterY = 700.0;

  /// Get the world position for a grid cell
  static Vector2 gridToWorld(int row, int col, double screenWidth) {
    final isOddRow = row % 2 == 1;
    final offsetX = isOddRow ? GameConfig.bubbleRadius : 0;

    // Calculate grid width to center it properly
    // Even rows: 9 bubbles, Odd rows: 8 bubbles (offset by half bubble)
    final gridWidth = (GameConfig.gridColumns - 1) * GameConfig.bubbleDiameter + GameConfig.bubbleDiameter;
    final centerOffsetX = (screenWidth - gridWidth) / 2 + GameConfig.gridOffsetX;

    final x = centerOffsetX +
        offsetX +
        GameConfig.bubbleRadius +
        col * GameConfig.bubbleDiameter;

    final y = safeAreaTop +
        GameConfig.gridOffsetY +
        GameConfig.bubbleRadius +
        row * GameConfig.rowHeight;

    return Vector2(x, y);
  }

  /// Get the nearest grid position for a world position
  static (int row, int col) worldToGrid(Vector2 position, double screenWidth) {
    // Calculate approximate row
    int row = ((position.y - safeAreaTop - GameConfig.gridOffsetY - GameConfig.bubbleRadius) /
            GameConfig.rowHeight)
        .round();
    row = row.clamp(0, GameConfig.maxGridRows - 1);

    // Calculate column based on row (odd rows are offset)
    final isOddRow = row % 2 == 1;
    final offsetX = isOddRow ? GameConfig.bubbleRadius : 0;

    // Calculate grid center offset
    final gridWidth = (GameConfig.gridColumns - 1) * GameConfig.bubbleDiameter + GameConfig.bubbleDiameter;
    final centerOffsetX = (screenWidth - gridWidth) / 2 + GameConfig.gridOffsetX;

    int col = ((position.x - centerOffsetX - offsetX - GameConfig.bubbleRadius) /
            GameConfig.bubbleDiameter)
        .round();

    // Clamp column
    final maxCols = getColumnsForRow(row);
    col = col.clamp(0, maxCols - 1);

    return (row, col);
  }

  /// Get the number of columns for a given row
  static int getColumnsForRow(int row) {
    // Odd rows have one less column due to offset
    return row % 2 == 1 ? GameConfig.gridColumns - 1 : GameConfig.gridColumns;
  }

  /// Get adjacent cell positions for a given cell
  static List<(int, int)> getAdjacentCells(int row, int col) {
    final List<(int, int)> adjacent = [];
    final isOddRow = row % 2 == 1;

    // Even row neighbors
    // Top-left, Top-right, Left, Right, Bottom-left, Bottom-right
    final evenRowOffsets = [
      (-1, -1), // top-left
      (-1, 0), // top-right
      (0, -1), // left
      (0, 1), // right
      (1, -1), // bottom-left
      (1, 0), // bottom-right
    ];

    // Odd row neighbors
    final oddRowOffsets = [
      (-1, 0), // top-left
      (-1, 1), // top-right
      (0, -1), // left
      (0, 1), // right
      (1, 0), // bottom-left
      (1, 1), // bottom-right
    ];

    final offsets = isOddRow ? oddRowOffsets : evenRowOffsets;

    for (final offset in offsets) {
      final newRow = row + offset.$1;
      final newCol = col + offset.$2;

      // Check bounds
      if (newRow >= 0 && newRow < GameConfig.maxGridRows) {
        final maxCols = getColumnsForRow(newRow);
        if (newCol >= 0 && newCol < maxCols) {
          adjacent.add((newRow, newCol));
        }
      }
    }

    return adjacent;
  }

  /// Calculate distance between two grid cells
  static double distance(int row1, int col1, int row2, int col2, double screenWidth) {
    final pos1 = gridToWorld(row1, col1, screenWidth);
    final pos2 = gridToWorld(row2, col2, screenWidth);
    return pos1.distanceTo(pos2);
  }

  /// Check if a position is within the grid bounds
  static bool isValidPosition(int row, int col) {
    if (row < 0 || row >= GameConfig.maxGridRows) return false;
    final maxCols = getColumnsForRow(row);
    return col >= 0 && col < maxCols;
  }
}
