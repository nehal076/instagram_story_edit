import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'sketcher.dart';
import 'drawn_line.dart';

class Painter extends StatefulWidget {
  final void Function(String?) getText;
  final bool showControls;
  final void Function() onSave;
  const Painter(
      {super.key,
      required this.getText,
      required this.onSave,
      required this.showControls});

  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine? line;
  Color selectedColor = Colors.red;
  double selectedWidth = 5.0;
  ScreenshotController screenshotController = ScreenshotController();

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  addText() {
    FocusScope.of(context).requestFocus(_focusNode);
    widget.getText(_controller.text);
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
      _controller.text = '';
      widget.getText('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          Visibility(
            visible: widget.showControls,
            child: buildStrokeToolbar(),
          ),
          Visibility(
            visible: widget.showControls,
            child: buildColorToolbar(),
          ),
          buildTextInput(context),
        ],
      ),
    );
  }

  buildTextInput(context) {
    return Positioned(
      top: 70.0,
      right: 30.0,
      child: SizedBox(
        width: 20,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (value) {
            widget.getText(_controller.text);
          },
          cursorColor: Colors.transparent,
          showCursor: false,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.transparent),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: line != null
                    ? Sketcher(
                        lines: [line!],
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.topLeft,
      child: StreamBuilder<List<DrawnLine>>(
        stream: linesStreamController.stream,
        builder: (context, snapshot) {
          return CustomPaint(
            painter: Sketcher(
              lines: lines,
            ),
          );
        },
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line!);

    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildClearButton(),
          const Divider(height: 10.0),
          buildTextButton(),
          const Divider(height: 10.0),
          buildSaveButton(),
          const Divider(height: 20.0),
          buildColorButton(Colors.red),
          buildColorButton(Colors.blueAccent),
          buildColorButton(Colors.deepOrange),
          buildColorButton(Colors.green),
          buildColorButton(Colors.pink),
          buildColorButton(Colors.black),
          buildColorButton(Colors.white),
        ],
      ),
    );
  }

  Widget buildTextButton() {
    return GestureDetector(
      onTap: addText,
      child: const CircleAvatar(
        child: Icon(
          Icons.text_fields_sharp,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: widget.onSave,
      child: const CircleAvatar(
        child: Icon(
          Icons.download,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.backspace,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
