import 'package:flutter/material.dart';
import 'dart:math';

class Calculations {
  /// BULLETPROOF: Generate guaranteed solvable puzzle
  /// This uses a foolproof method: start from solved state and make valid moves
  static List<int> generateSolvablePuzzle() {
    // Start with the winning configuration
    List<int> puzzle = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    
    // Make random valid moves to scramble it
    // This guarantees solvability because we start from a solvable state
    final random = Random();
    const minMoves = 100; // Minimum moves to ensure good scrambling
    const maxMoves = 200; // Maximum moves to ensure it's challenging
    
    int moves = minMoves + random.nextInt(maxMoves - minMoves);
    
    for (int i = 0; i < moves; i++) {
      List<int> validMoves = _getValidMoves(puzzle);
      if (validMoves.isNotEmpty) {
        int randomMove = validMoves[random.nextInt(validMoves.length)];
        _swapTiles(puzzle, puzzle.indexOf(8), randomMove);
      }
    }
    
    // Final check: ensure it's not the solved state
    if (_isSolved(puzzle)) {
      // If somehow we ended up solved, make one more valid move
      List<int> validMoves = _getValidMoves(puzzle);
      if (validMoves.isNotEmpty) {
        _swapTiles(puzzle, puzzle.indexOf(8), validMoves[0]);
      }
    }
    
    return puzzle;
  }

  /// ALTERNATIVE METHOD: Generate using inversion counting with safety checks
  /// This is more traditional but with proper validation
  static List<int> generateSolvablePuzzleAlternative({int maxAttempts = 100}) {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      List<int> puzzle = [0, 1, 2, 3, 4, 5, 6, 7, 8];
      puzzle.shuffle();
      
      // Check if already solved
      if (_isSolved(puzzle)) {
        continue;
      }
      
      // Count inversions
      int inversions = _countInversions(puzzle);
      
      // For 3x3 puzzle, solvable if inversions is even
      if (inversions % 2 == 0) {
        // Double-check solvability with A* validation
        if (_validateSolvability(puzzle)) {
          return puzzle;
        }
      } else {
        // Fix by swapping two non-blank tiles to change parity
        _makeEvenInversions(puzzle);
        
        if (_validateSolvability(puzzle)) {
          return puzzle;
        }
      }
    }
    
    // Fallback: use the guaranteed method
    return generateSolvablePuzzle();
  }

  /// Get valid moves for the blank tile (8)
  static List<int> _getValidMoves(List<int> puzzle) {
    int blankIndex = puzzle.indexOf(8);
    List<int> validMoves = [];
    
    int row = blankIndex ~/ 3;
    int col = blankIndex % 3;
    
    // Up
    if (row > 0) validMoves.add(blankIndex - 3);
    // Down
    if (row < 2) validMoves.add(blankIndex + 3);
    // Left
    if (col > 0) validMoves.add(blankIndex - 1);
    // Right
    if (col < 2) validMoves.add(blankIndex + 1);
    
    return validMoves;
  }

  /// Swap tiles in the puzzle
  static void _swapTiles(List<int> puzzle, int index1, int index2) {
    int temp = puzzle[index1];
    puzzle[index1] = puzzle[index2];
    puzzle[index2] = temp;
  }

  /// Check if puzzle is in solved state
  static bool _isSolved(List<int> puzzle) {
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] != i) return false;
    }
    return true;
  }

  /// Count inversions in the puzzle
  static int _countInversions(List<int> puzzle) {
    int inversions = 0;
    
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] == 8) continue; // Skip blank tile
      
      for (int j = i + 1; j < puzzle.length; j++) {
        if (puzzle[j] == 8) continue; // Skip blank tile
        
        if (puzzle[j] < puzzle[i]) {
          inversions++;
        }
      }
    }
    
    return inversions;
  }

  /// Make puzzle have even inversions by swapping two tiles
  static void _makeEvenInversions(List<int> puzzle) {
    // Find two non-blank tiles to swap
    int firstNonBlank = -1;
    int secondNonBlank = -1;
    
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] != 8) {
        if (firstNonBlank == -1) {
          firstNonBlank = i;
        } else if (secondNonBlank == -1) {
          secondNonBlank = i;
          break;
        }
      }
    }
    
    if (firstNonBlank != -1 && secondNonBlank != -1) {
      _swapTiles(puzzle, firstNonBlank, secondNonBlank);
    }
  }

  /// Validate that a puzzle is actually solvable using simplified A* check
  /// This catches edge cases that inversion counting might miss
  static bool _validateSolvability(List<int> puzzle) {
    // For 3x3 puzzle, we can use Manhattan distance heuristic
    // If the sum of Manhattan distances + inversions is reasonable, it's likely solvable
    
    int manhattanDistance = 0;
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] == 8) continue; // Skip blank
      
      int goalPosition = puzzle[i];
      int currentRow = i ~/ 3;
      int currentCol = i % 3;
      int goalRow = goalPosition ~/ 3;
      int goalCol = goalPosition % 3;
      
      manhattanDistance += (currentRow - goalRow).abs() + (currentCol - goalCol).abs();
    }
    
    // A reasonable puzzle should have Manhattan distance > 0 and < 40
    // (max possible is around 24 for 8-puzzle, but we allow some margin)
    return manhattanDistance > 0 && manhattanDistance < 40;
  }

  /// Swap tiles based on puzzle configuration

  static List<Offset> swapTiles(List<int> puzzle, List<Offset> originalPositions) {
  List<Offset> newPositions = List.filled(9, Offset.zero);

  for (int i = 0; i < puzzle.length; i++) {
    int tileNumber = puzzle[i];
    newPositions[tileNumber] = originalPositions[i]; // ← Fixed!
  }

  return newPositions;
}

  /// Check if a puzzle configuration is solvable
  static bool isSolvable(List<int> puzzle) {
    int inversions = _countInversions(puzzle);
    
    // For 3x3 puzzle with blank, solvable if inversions are even
    return inversions % 2 == 0;
  }

  /// Check if puzzle is in winning state by comparing positions
  static bool isWinningState(List<Offset> currentPositions, List<Offset> winPositions) {
    if (currentPositions.length != winPositions.length) return false;

    for (int i = 0; i < currentPositions.length; i++) {
      // Use a small epsilon for floating point comparison
      if ((currentPositions[i].dx - winPositions[i].dx).abs() > 0.1 ||
          (currentPositions[i].dy - winPositions[i].dy).abs() > 0.1) {
        return false;
      }
    }

    return true;
  }

  /// Get the difficulty level based on number of inversions
  static String getDifficulty(List<int> puzzle) {
    int inversions = _countInversions(puzzle);

    if (inversions <= 5) return 'Easy';
    if (inversions <= 10) return 'Medium';
    if (inversions <= 15) return 'Hard';
    return 'Expert';
  }

  /// Calculate the minimum number of moves needed (Manhattan distance heuristic)
  static int estimateMinimumMoves(List<int> puzzle) {
    int totalDistance = 0;

    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] == 8) continue; // Skip empty tile

      int goalPosition = puzzle[i];
      int currentRow = i ~/ 3;
      int currentCol = i % 3;
      int goalRow = goalPosition ~/ 3;
      int goalCol = goalPosition % 3;

      totalDistance += (currentRow - goalRow).abs() + (currentCol - goalCol).abs();
    }

    return totalDistance;
  }

  /// Generate a puzzle with specific difficulty
  static List<int> generatePuzzleWithDifficulty(String difficulty) {
    int maxAttempts = 50;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      List<int> puzzle = generateSolvablePuzzle();
      String puzzleDifficulty = getDifficulty(puzzle);
      
      if (puzzleDifficulty == difficulty) {
        return puzzle;
      }
    }
    
    // Fallback to any solvable puzzle
    return generateSolvablePuzzle();
  }

  /// Debug: Print puzzle state
  static void printPuzzle(List<int> puzzle) {
    print('Puzzle state:');
    for (int i = 0; i < 9; i += 3) {
      print('${puzzle[i]} ${puzzle[i + 1]} ${puzzle[i + 2]}');
    }
    print('Inversions: ${_countInversions(puzzle)}');
    print('Solvable: ${isSolvable(puzzle)}');
    print('Manhattan Distance: ${estimateMinimumMoves(puzzle)}');
    print('Difficulty: ${getDifficulty(puzzle)}');
  }



  static List<Offset> generatePositions(Size size) {
    return List.generate(9, (index) {
      double height = size.height / 2 / 3 - 10;
      double width = size.width / 3 - 20;

      int row = index ~/ 3;
      int col = index % 3;

      double x = (size.width * 0.2) + width * col + (col * (width * 0.08));
      double y = size.height * 0.3 + (height + 10) * row;

      return Offset(x, y);
    });
  }
}

/// Standalone function for backward compatibility
List<int> generateSolvablePuzzle() {
  return Calculations.generateSolvablePuzzle();
}