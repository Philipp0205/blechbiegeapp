import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/drawing_page_bloc.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_event.dart';
import 'package:open_bsp/bloc%20/drawing_page/segment_widget/drawing_widget_state.dart';
import 'package:open_bsp/pages/drawing_page/two_coloumn_portrait_layout.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';
import '../../bloc /drawing_page/segment_widget/drawing_widget_bloc.dart';
import '../../model/line.dart';
import 'drawing_widget.dart';

/// On this page the user can draw a single line representing the the profile
/// of a metal sheet.
///
/// The length and angle of the lines can be changed in a bottom sheet.
class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  /// TextField controllers
  final _angleController = TextEditingController();
  final _lengthController = TextEditingController();
  final _calcService = new GeometricCalculationsService();

  @override
  void initState() {
    super.initState();

    List<Line> selectedLines = context
        .read<DrawingWidgetBloc>()
        .state
        .lines
        .where((element) => element.isSelected)
        .toList();

    if (selectedLines.isNotEmpty) {
      _setAngle(selectedLines);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _angleController.dispose();
    _lengthController.dispose();
  }

  /// Sets the initial angle in the angle text field.
  /// When there are multiple [Line]s selected it show only the angle of
  /// the first Line.
  void _setAngle(List<Line> lines) {
    if (lines.length == 1) {
      _angleController.text = _calcService
          .getAngle(lines.first.start, lines.first.end)
          .toStringAsFixed(1);
    } else {
      _angleController.text = _calcService
          .getInnerAngle(lines.first, lines.last)
          .toStringAsFixed(1);
    }
  }

  /// Sets the initial length in the length text field.
  /// When multiple lines are selected the length of the last selected line
  /// is used.
  void _setLength(List<Line> lines) {
    Line line = lines.last;
    double distance = (line.start - line.end).distance;
    _lengthController.text = distance.toStringAsFixed(1);
  }

  /// Building a widget containing a [DrawingWidget], one row where the eiditing
  /// Mode can be changed and one row where the angle and the length of the
  /// line can be changed.
  @override
  Widget build(BuildContext context) {
    /// Triggers when a new line is selected and there the [TextField]s get new
    /// values.
    return BlocListener<DrawingWidgetBloc, DrawingWidgetState>(
      listenWhen: (prev, current) =>
          prev.selectedLines != current.selectedLines &&
          current.selectedLines.isNotEmpty,
      listener: (context, state) {
        _setAngle(state.selectedLines);
        _setLength(state.selectedLines);
      },

      /// Rebuild the Widget if [DrawingPageState] changes.
      child: BlocBuilder<DrawingPageBloc, DrawingPageState>(
          builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Blechprofil zeichnen'),
                Container(width: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _undo();
                        },
                        icon: Icon(Icons.arrow_circle_left)),
                    SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          _redo();
                        },
                        icon: Icon(Icons.arrow_circle_right)),
                  ],
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: OrientationBuilder(builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? buildPortraitLayout(state)
                : buildLandscapeLayout(state);
          }),
          floatingActionButton: Stack(
            children: [
              /// Right Button
              Positioned(
                bottom: 20,
                right: 10,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_right),
                  onPressed: () => _goToNextPage(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Builds the vertical layout of the page.
  /// The [DrawingWidget] is followed by two rows containing the options for
  /// configuring the line.
  ///
  /// The first row contains the selecting and deleting the line and the second row contains the
  /// angle and the length of the line.
  TwoColumnPortraitLayout buildPortraitLayout(DrawingPageState state) {
    return TwoColumnPortraitLayout(
      upperRow: Row(
        children: [Expanded(child: DrawingWidget())],
      ),
      lowerColumn: Column(
        children: [
          for (var widget in _buildMenuHeader()) widget,
          Divider(
            height: 20,
          ),
          Row(
            children: [
              Flexible(child: _buildAngleTextField()),
              SizedBox(width: 10),
              Flexible(child: _buildLengthTextField()),
              SizedBox(width: 10),
              Flexible(child: _buildSelectLineCheckboxListTile(state)),
              SizedBox(width: 10),
              Flexible(child: _buildDeleteElevatedButton()),
            ],
          ),
          Divider(height: 20),
        ],
      ),
    );
  }

  Row buildLandscapeLayout(DrawingPageState state) {
    return Row(
      children: [
        Flexible(
          flex: 20,
          child: Column(
            children: [
              for (var widget in _buildMenuHeader()) widget,
              Divider(),
              buildConfigRow22(state),
              _buildSelectLineCheckboxListTile(state),
              SizedBox(
                width: 500,
                child: _buildDeleteElevatedButton(),
              )
            ],
          ),
        ),
        Spacer(),
        Flexible(
          flex: 80,
          child: Column(
            children: [
              DrawingWidget(),
            ],
          ),
        ),
      ],
    );
  }

  ElevatedButton _buildDeleteElevatedButton() {
    return ElevatedButton(
        onPressed: () => _clearCanvas(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete),
            SizedBox(
              width: 10,
            ),
            Text('Profil löschen')
          ],
        ));
  }

  List<Widget> _buildMenuHeader() {
    return [
      Text('Konfiguration', style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 10,
      ),
      Text('Kante selektieren um Länge und Winkel anzupassen.',
          style: Theme.of(context).textTheme.subtitle1)
    ];
  }

  Widget buildDrawingWidget() {
    return Stack(children: [
      DrawingWidget(),
    ]);
  }

  CheckboxListTile _buildSelectLineCheckboxListTile(DrawingPageState state) {
    return CheckboxListTile(
        title: Text('Linie selektieren'),
        value: state.selectionMode,
        onChanged: (bool? value) {
          _toggleSelectionMode(value!);
        });
  }

  Row buildLineConfigRow() {
    return Row(
      children: [
        TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Winkel',
            ),
            onChanged: (text) {
              double? value = double.tryParse(text);
              if (value != null) {
                _changeAngle(value);
              }
            },
            controller: _angleController,
            keyboardType: TextInputType.number),
        Text('Winkel'),
        Container(
          width: 50,
          height: 30,
          child: TextField(
              onChanged: (text) {
                double? value = double.tryParse(text);
                if (value != null) {
                  context.read<DrawingWidgetBloc>().add(
                      LineDrawingLengthChanged(
                          length: double.parse(_lengthController.text)));
                }
              },
              controller: _lengthController,
              keyboardType: TextInputType.number),
        ),
        Text('Länge'),
      ],
    );
  }

  Column buildConfigRow22(DrawingPageState state) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(child: _buildAngleTextField()),
            // SizedBox(width: 245, child: _buildAngleTextField()),
          ],
        ),
        SizedBox(height: 10),
        Row(children: [
          Flexible(child: _buildLengthTextField()),
          // SizedBox(
          //   width: 245,
          //   child: _buildLengthTextField(),
          // ),
        ]),
      ],
    );
  }

  Widget buildConfigRow2(DrawingPageState state) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.landscape
            ? buildPortraitLengthAndAngleRow()
            : buildConfigRow22(state);
      },
    );
  }

  Row buildPortraitLengthAndAngleRow() {
    return Row(
      children: [
        Container(
          width: 100,
          child: _buildAngleTextField(),
        ),
        Container(width: 20),
        Container(
          width: 100,
          child: _buildLengthTextField(),
        )
      ],
    );
  }

  TextField _buildLengthTextField() {
    return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Länge (mm)',
        ),
        onChanged: (text) {
          double? value = double.tryParse(text);
          if (value != null) {
            context.read<DrawingWidgetBloc>().add(LineDrawingLengthChanged(
                length: double.parse(_lengthController.text)));
          }
        },
        controller: _lengthController,
        keyboardType: TextInputType.number);
  }

  TextField _buildAngleTextField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Winkel (mm)',
      ),
      onChanged: (text) {
        double? value = double.tryParse(text);
        if (value != null) {
          _changeAngle(value);
        }
      },
      controller: _angleController,
      keyboardType: TextInputType.number,
    );
  }

  /// Deletes all drawn lines.
  Future<void> _clearCanvas() async {
    BlocProvider.of<DrawingWidgetBloc>(context).add((LinesDeleted()));
  }

  /// Toggles the selection mode in which the user can select one ore multiple
  /// [Line]s.
  void _toggleSelectionMode(bool value) {
    context
        .read<DrawingPageBloc>()
        .add(DrawingPageSelectionModeChanged(selectionMode: value));
  }

  /// Navigates to the next Page and passes the selected lines to the next Page.
  void _goToNextPage() {
    List<Line> lines = context.read<DrawingWidgetBloc>().state.lines;

    BlocProvider.of<ConfigPageBloc>(context)
        .add(ConfigPageCreated(lines: lines, tools: []));

    Navigator.of(context).pushNamed('/config');
  }

  /// Undo the last action.
  void _undo() {
    context.read<DrawingWidgetBloc>().add(LineDrawingUndo());
  }

  /// Redo the last action.
  void _redo() {
    context.read<DrawingWidgetBloc>().add(LineDrawingRedo());
  }

  /// Changes the angle of the selected [Line]s.
  /// Note that different events are triggered depending on the number of
  /// selected [Line]s.
  void _changeAngle(double value) {
    List<Line> selectedLines =
        context.read<DrawingWidgetBloc>().state.selectedLines;

    if (selectedLines.length == 1) {
      context.read<DrawingWidgetBloc>().add(LineDrawingAngleChanged(
          angle: value, length: double.parse(_lengthController.text)));
    } else {
      context.read<DrawingWidgetBloc>().add(LineDrawingInnerAngleChanged(
          angle: value, length: double.parse(_lengthController.text)));
    }
  }
}
