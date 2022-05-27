part of 'current_path_bloc.dart';

abstract class CurrentPathState extends Equatable {
  final List<Segment> currentSegment;

  const CurrentPathState({required this.currentSegment});

  @override
  List<Object> get props => [];
}

class CurrentSegmentInitial extends CurrentPathState {
  final List<Segment> currentSegment;

  const CurrentSegmentInitial({required this.currentSegment})
      : super(currentSegment: currentSegment);
}

class CurrentSegmentUpdate extends CurrentPathState {
  final List<Segment> segment;

  const CurrentSegmentUpdate({required this.segment})
      : super(currentSegment: segment);

  @override
  List<Object> get props => [currentSegment];
}


