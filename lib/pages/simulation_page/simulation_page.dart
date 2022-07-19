import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/bloc%20/simulation_page/simulation_sketcher.dart';

import '../../bloc /shapes_page/tool_page_bloc.dart';
import '../../model/simulation/tool.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({Key? key}) : super(key: key);

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  @override
  Widget build(BuildContext context) {
    // Listens for changes in the tool selection.
    return MultiBlocListener(
      listeners: [
        BlocListener<ToolPageBloc, ToolPageState>(
          listenWhen: (prev, current) => prev.beams != current.beams,
          listener: (context, state) {
            _setSelectedBeams(context, state.beams);
            _setSelectedTracks(context, state.beams);
          },
        )
      ],
      child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
          builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: buildAppBar(),
          backgroundColor: Colors.white,
          body: buildBody(),
        );
      }),
    );
  }

  /// Builds the body of the app.
  Container buildBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [buildSketcher(), buildButtonRow()],
        ),
      ),
    );
  }

  /// Build a row containing the buttons for adding tools and bending tools.
  Row buildButtonRow() {
    return Row(
      children: [
        ElevatedButton(
            onPressed: () => _openSelectBeamPage(), child: Text('Wangen')),
        Container(width: 10),
        ElevatedButton(
            onPressed: () => _openSelectTrackPage(), child: Text('Schienen')),
      ],
    );
  }

  /// Builds the sketcher area of the page where the simulation takes place.
  Container buildSketcher() {
    return Container(
        height: 300,
        width: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: BlocBuilder<SimulationPageBloc, SimulationPageState>(
            builder: (context, state) {
          return CustomPaint(
            painter: SimulationSketcher(
                beams: state.selectedBeams, tracks: state.selectedTracks),
          );
        }));
  }

  /// Build the appbar of the the page.
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Simulation')],
      ),
    );
  }

  /// Open the [ToolPage] to select beams.
  void _openSelectBeamPage() {
    Navigator.of(context).pushNamed("/shapes");
  }

  /// Open the [ToolPage] to select tracks.
  void _openSelectTrackPage() {
    Navigator.of(context).pushNamed("/shapes");
  }

  /// Set the selected beams for the sketcher.
  /// This is done by listening to the [ToolPageBloc] and setting the selected
  /// beams.
  /// The [ToolPageBloc] is listening to the [SimulationPageBloc] and setting
  /// the selected beams.
  /// Therefore, this method is called when the [ToolPageBloc] changes.
  void _setSelectedBeams(BuildContext context, List<Tool> tools) {
    List<Tool> selectedTools = tools.where((tool) => tool.isSelected).toList();

    context
        .read<SimulationPageBloc>()
        .add(SimulationSelectedToolsChanged(selectedTools: selectedTools));
  }

  /// Set the selected tracks for the sketcher.
  /// This is done by listening to the [ToolPageBloc] and setting the selected
  /// tracks.
  /// The [ToolPageBloc] is listening to the [SimulationPageBloc] and setting
  /// the selected tracks.
  /// Therefore, this method is called when the [ToolPageBloc] changes.
  void _setSelectedTracks(BuildContext context, List<Tool> tools) {
    List<Tool> selectedTracks = tools.where((tool) => tool.isSelected).toList();
    // tools.where((tool) => tool.isSelected).toList().where((tool) => tool.type.type)
    context
        .read<SimulationPageBloc>()
        .add(SimulationSelectedTracksChanged(selectedTracks: selectedTracks));
  }
}
