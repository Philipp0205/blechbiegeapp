import 'package:hive_flutter/hive_flutter.dart';

import 'tool_type2.dart';
import '../line.dart';

part 'tool.g.dart';

/// Represents a simple shape. For example different tools for bending metal
/// sheets.
@HiveType(typeId: 1)
class Tool {
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Line> lines;
  @HiveField(3)
  final ToolType2 type;
  @HiveField(4)
  final bool isSelected;
  @HiveField(5)
  final List<Line> adapterLine;
  @HiveField(6)
  final ToolCategory category;

  const Tool(
      {required this.name,
      required this.lines,
      required this.type,
      required this.isSelected,
      required this.adapterLine,
      required this.category});

  Tool copyWith({
    String? name,
    List<Line>? lines,
    ToolType2? type,
    bool? isSelected,
    List<Line>? adapterLine,
    ToolCategory? category,
  }) {
    return Tool(
      name: name ?? this.name,
      lines: lines ?? this.lines,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      adapterLine: adapterLine ?? this.adapterLine,
      category: category ?? this.category,
    );
  }
}

enum ToolCategory {
  BEAM,
  TRACK,
}
