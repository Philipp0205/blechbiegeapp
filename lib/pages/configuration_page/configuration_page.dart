import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_bsp/pages/configuration_page/add_shape_bottom_sheet.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../model/segment_widget/segment.dart';
import 'config_page_segment_widget.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool showCoordinates = true;
  bool showEdgeLengths = false;

  final _sController = TextEditingController();
  final _rController = TextEditingController();

  @override
  void initState() {
    super.initState();

    double s = context.read<ConfigPageBloc>().state.s;
    double r = context.read<ConfigPageBloc>().state.r;
    _sController.text = s.toStringAsFixed(0);

    _rController.text = r.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _sController.dispose();
    _rController.dispose();
    super.dispose();
  }

  /// Build the page containing the [ConstructingSegmentWidget] which draw the
  /// line, a row of [Checkbox]es to show differents details of the line and
  /// a row of [TextField]s to configure the drawn line.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigPageBloc, ConfigPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp')],
          ),
        ),
        backgroundColor: Colors.white,
        floatingActionButton: buildLeftFloatingActionButton(state, context),
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ConstructingPageSegmentWidget(),
              ),
              buildCheckboxRow(state, context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              buildTextFieldRow(context),
            ],
          ),
        ),
      );
    });
  }

  /// [TextField]s where the user can change the metal sheet thickness and
  /// the radius of the curves.
  Padding buildTextFieldRow(BuildContext context) {
    return Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    child: TextField(
                        controller: _sController,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          double? angle = double.tryParse(_sController.text);
                          if (angle != null) {
                            context
                                .read<ConfigPageBloc>()
                                .add(ConfigSChanged(s: angle));
                          }
                        }),
                  ),
                  Text('Bleckdicke (s)   '),
                  Container(
                    width: 30,
                    height: 30,
                    child: TextField(
                        controller: _rController,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          double? value = double.tryParse(text);
                          if (value != null) {
                            context.read<ConfigPageBloc>().add(ConfigRChanged(
                                r: double.parse(_rController.text)));
                          }
                        }),
                  ),
                  Text('Radius (r)'),
                ],
              ),
            );
  }

  /// [Row] containing checkboxes for showing different details of the drawn
  /// [Line]s.
  Row buildCheckboxRow(ConfigPageState state, BuildContext context) {
    return Row(
              children: [
                Checkbox(
                    value: state.showCoordinates,
                    onChanged: (bool? value) {
                      context.read<ConfigPageBloc>().add(
                          ConfigCoordinatesShown(showCoordinates: value!));
                      print('checkbox');
                    }),
                Text('Koordinaten'),
                Checkbox(
                    value: state.showEdgeLengths,
                    onChanged: (bool? value) {
                      context.read<ConfigPageBloc>().add(
                          ConfigEdgeLengthsShown(showEdgeLengths: value!));
                    }),
                Text('Längen'),
                Checkbox(
                    value: state.showAngles,
                    onChanged: (bool? value) {
                      context
                          .read<ConfigPageBloc>()
                          .add(ConfigAnglesShown(showAngles: value!));
                    }),
                Text('Winkel')
              ],
            );
  }

  /// Builds the left [FloatingActionButton].
  Stack buildLeftFloatingActionButton(ConfigPageState state, BuildContext context) {
    return Stack(
        children: [
          /// Left Button
          Positioned(
            left: 40,
            bottom: 20,
            child: SpeedDial(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              icon: Icons.add,
              activeIcon: Icons.close,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.add),
                  onTap: () => _createShape(state.segment.first),
                ),
              ],
            ),
          ),

          /// Right Button
          Positioned(
            bottom: 20,
            right: 10,
            child: FloatingActionButton(
              heroTag: "btn2",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_right),
              onPressed: () => Navigator.of(context).pushNamed("/third"),
            ),
          ),
        ],
      );
  }

  void _createShape(Segment segment) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddShapeBottomSheet();
      },
    );
  }
}
