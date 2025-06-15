//  import 'package:get/get.dart';
// import 'package:npuzzle/calculations.dart';
// import 'package:npuzzle/ground.dart';
// import 'package:npuzzle/levels.dart';

// nextLevel(int index) {
//     Get.back();
//     Get.to(index < 24
//         ? TilesGround(
//             level: index + 1,
//             size: widget.size,
//             position: Calculations.swapTiles(
//                 Levels.levels[index], Levels.winposition),
//             comparizon1: widget.comparizon1,
//             comparizon2: widget.comparizon2,
//             highLevel: widget.highLevel,
//           )
//         : TilesGround(
//             level: index + 1,
//             size: widget.size,
//             position: Calculations.swapTiles(
//                 Calculations.generateSolvabePuzzle(), Levels.winposition),
//             comparizon1: widget.comparizon1,
//             comparizon2: widget.comparizon2,
//             highLevel: widget.highLevel,
//           ));
//   }