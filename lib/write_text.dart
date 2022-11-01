import 'package:flutter/material.dart';

class WriteText extends StatefulWidget {
  final String? text;
  const WriteText({super.key, required this.text});

  @override
  State<WriteText> createState() => _WriteTextState();
}

class _WriteTextState extends State<WriteText> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return widget.text != null
        ? Positioned(
            left: offset.dx,
            top: offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  offset = Offset(offset.dx + details.delta.dx,
                      offset.dy + details.delta.dy);
                });
              },
              child: SizedBox(
                width: 300,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      widget.text!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
