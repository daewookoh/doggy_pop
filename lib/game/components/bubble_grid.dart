import 'package:flame/components.dart';
import 'dart:collection';

import '../../config/game_config.dart';
import '../../models/bubble_type.dart';
import '../../utils/hex_grid_utils.dart';
import '../bubble_game.dart';
import 'bubble.dart';

class BubbleGrid extends Component with HasGameReference<BubbleGame> {
  // 2D grid to store bubbles - initialized immediately
  List<List<Bubble?>> grid = List.generate(
    GameConfig.maxGridRows,
    (row) => List.filled(HexGridUtils.getColumnsForRow(row), null),
  );
  int initialBubbleCount = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Reposition all bubbles when game size changes
    _repositionAllBubbles();
  }

  void _repositionAllBubbles() {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        final bubble = grid[row][col];
        if (bubble != null) {
          bubble.position = getWorldPosition(row, col);
        }
      }
    }
  }

  void clearAll() {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        final bubble = grid[row][col];
        if (bubble != null) {
          bubble.removeFromParent();
          grid[row][col] = null;
        }
      }
    }
    initialBubbleCount = 0;
  }

  void generateLevel(int level) {
    clearAll();

    // Generate bubbles based on level
    int rows = 3 + (level ~/ 3); // More rows as level increases
    rows = rows.clamp(3, 8);

    int colorCount = 3 + (level ~/ 5); // More colors as level increases
    colorCount = colorCount.clamp(3, 6);

    final availableTypes = BubbleType.values.take(colorCount).toList();

    for (var row = 0; row < rows; row++) {
      final cols = HexGridUtils.getColumnsForRow(row);
      for (var col = 0; col < cols; col++) {
        // Skip some bubbles randomly for variety
        if (level > 1 && row > 1 && col % 3 == 0 && level % 2 == 0) {
          continue;
        }

        final type = BubbleTypeExtension.randomFrom(availableTypes);
        final bubble = Bubble(
          type: type,
          state: BubbleState.attached,
          position: getWorldPosition(row, col),
        );
        bubble.gridRow = row;
        bubble.gridCol = col;

        grid[row][col] = bubble;
        add(bubble);
        initialBubbleCount++;
      }
    }
  }

  Vector2 getWorldPosition(int row, int col) {
    return HexGridUtils.gridToWorld(row, col, game.size.x);
  }

  (int, int) getNearestGridPosition(Vector2 position) {
    return HexGridUtils.worldToGrid(position, game.size.x);
  }

  void attachBubble(Bubble bubble, int row, int col) {
    // Check if position is occupied, find nearby empty spot
    if (grid[row][col] != null) {
      final empty = _findNearestEmpty(row, col);
      if (empty != null) {
        row = empty.$1;
        col = empty.$2;
      }
    }

    bubble.gridRow = row;
    bubble.gridCol = col;
    bubble.position = getWorldPosition(row, col);
    bubble.state = BubbleState.attached;

    grid[row][col] = bubble;
    add(bubble);
  }

  (int, int)? _findNearestEmpty(int row, int col) {
    final adjacent = HexGridUtils.getAdjacentCells(row, col);
    for (final cell in adjacent) {
      if (grid[cell.$1][cell.$2] == null) {
        return cell;
      }
    }
    return null;
  }

  List<Bubble> findMatches(int row, int col) {
    final bubble = grid[row][col];
    if (bubble == null) return [];

    final targetType = bubble.type;
    final matched = <Bubble>[];
    final visited = <String>{};
    final queue = Queue<(int, int)>();

    queue.add((row, col));
    visited.add('$row,$col');

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final currentBubble = grid[current.$1][current.$2];

      if (currentBubble != null && currentBubble.type == targetType) {
        matched.add(currentBubble);

        final adjacent = HexGridUtils.getAdjacentCells(current.$1, current.$2);
        for (final cell in adjacent) {
          final key = '${cell.$1},${cell.$2}';
          if (!visited.contains(key)) {
            visited.add(key);
            final adjacentBubble = grid[cell.$1][cell.$2];
            if (adjacentBubble != null && adjacentBubble.type == targetType) {
              queue.add(cell);
            }
          }
        }
      }
    }

    // Remove matched bubbles from grid
    if (matched.length >= GameConfig.minMatchCount) {
      for (final b in matched) {
        if (b.gridRow != null && b.gridCol != null) {
          grid[b.gridRow!][b.gridCol!] = null;
        }
      }
    }

    return matched.length >= GameConfig.minMatchCount ? matched : [];
  }

  List<Bubble> findFloatingBubbles() {
    // Find all bubbles connected to ceiling using BFS
    final connected = <String>{};
    final queue = Queue<(int, int)>();

    // Start from top row
    for (var col = 0; col < grid[0].length; col++) {
      if (grid[0][col] != null) {
        queue.add((0, col));
        connected.add('0,$col');
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final adjacent = HexGridUtils.getAdjacentCells(current.$1, current.$2);

      for (final cell in adjacent) {
        final key = '${cell.$1},${cell.$2}';
        if (!connected.contains(key) && grid[cell.$1][cell.$2] != null) {
          connected.add(key);
          queue.add(cell);
        }
      }
    }

    // Find floating bubbles (not connected to ceiling)
    final floating = <Bubble>[];
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        final bubble = grid[row][col];
        if (bubble != null && !connected.contains('$row,$col')) {
          floating.add(bubble);
          grid[row][col] = null;
        }
      }
    }

    return floating;
  }

  bool get isEmpty {
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] != null) return false;
      }
    }
    return true;
  }

  bool hasReachedBottom() {
    // Check if any bubble is in the danger zone (near shooter)
    const dangerRow = GameConfig.maxGridRows - 3;
    for (var row = dangerRow; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] != null) return true;
      }
    }
    return false;
  }

  List<BubbleType> getAvailableTypes() {
    final types = <BubbleType>{};
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        final bubble = grid[row][col];
        if (bubble != null) {
          types.add(bubble.type);
        }
      }
    }
    return types.isEmpty ? [BubbleType.red, BubbleType.blue, BubbleType.green] : types.toList();
  }
}
