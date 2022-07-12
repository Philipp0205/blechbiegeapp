import 'package:hive/hive.dart';

import '../../model/simulation/tool.dart';
import '../database_provider.dart';

class ToolRepository {
  final DatabaseProvider databaseProvider;

  ToolRepository(this.databaseProvider);

  /// get all tools from the database.
  Future<List<Tool>> getTools() async {
    Box box = await databaseProvider.createBox('tools2');
    print('getTools ${box.values.length}');
    return box.toMap().values.toList().cast<Tool>();
  }

  // Add given [tool] to the database.
  Future<void> addTool(Tool tool) async {
    Box box = await databaseProvider.createBox('tools2');
    String key =  _getKey(tool);
    box.put(key, tool);
  }

  /// Delete the tool with the given [index].
  Future<void> deleteTool(Tool tool) async {
    print('repo delete tool ${tool.name}');
    Box box = await databaseProvider.createBox('tools2');
    String key = _getKey(tool);
    box.delete(key);
  }

  /// Update given [tool] in the database.
  Future<void> updateTool(Tool oldTool, Tool tool) async {
    Box box = await databaseProvider.createBox('tools2');
    String key = _getKey(oldTool);
    box.put(key, tool);
  }

  /// Delete all tools from the database.
  Future<void> deleteAllTools() async {
    Box box = await databaseProvider.createBox('tools2');
    box.clear();
  }

  String _getKey(Tool tool) {
    return tool.name.toLowerCase().replaceAll(' ', '-');
  }

}