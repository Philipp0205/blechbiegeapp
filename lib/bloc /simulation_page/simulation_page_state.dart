part of 'simulation_page_bloc.dart';

class SimulationPageState extends Equatable {
  final List<Tool> shapes;
  final List<Line> lines;
  final List<Tool> selectedBeams;
  final List<Tool> selectedTracks;
  final List<Tool> selectedPlates;
  final double rotationAngle;
  final bool inCollision;

  // Will be removed later.
  final List<Offset> collisionOffsets;

  const SimulationPageState({
    required this.shapes,
    required this.lines,
    required this.selectedPlates,
    required this.selectedBeams,
    required this.selectedTracks,
    required this.rotationAngle,
    required this.collisionOffsets,
    required this.inCollision,
  });

  @override
  List<Object> get props => [
        shapes,
        lines,
        selectedBeams,
        selectedTracks,
        selectedPlates,
        rotationAngle,
        collisionOffsets,
        inCollision,
      ];

  SimulationPageState copyWith({
    List<Tool>? shapes,
    List<Line>? lines,
    List<Tool>? selectedBeams,
    List<Tool>? selectedTracks,
    List<Tool>? selectedPlates,
    double? rotationAngle,
    bool? inCollision,
    List<Offset>? debugOffsets,
  }) {
    return SimulationPageState(
      shapes: shapes ?? this.shapes,
      lines: lines ?? this.lines,
      selectedBeams: selectedBeams ?? this.selectedBeams,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      selectedPlates: selectedPlates ?? this.selectedPlates,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      inCollision: inCollision ?? this.inCollision,
      collisionOffsets: debugOffsets ?? this.collisionOffsets,
    );
  }
}

/// Initial values when the Bloc is created the first time.
class SimulationPageInitial extends SimulationPageState {
  SimulationPageInitial({
    required List<Tool> tools,
    required List<Tool> selectedBeams,
    required List<Tool> selectedTracks,
    required List<Tool> selectedPlates,
    required List<Line> lines,
    required double rotationAngle,
    required List<Offset> debugOffsets,
    required bool inCollision,
  }) : super(
          shapes: tools,
          lines: lines,
          selectedPlates: selectedPlates,
          selectedBeams: selectedBeams,
          selectedTracks: selectedTracks,
          rotationAngle: rotationAngle,
          collisionOffsets: debugOffsets,
          inCollision: inCollision,
        );
}
