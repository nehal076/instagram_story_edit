import 'package:flutter/material.dart';

class Loader {
  static show(BuildContext context, [String? label]) {
    return showDialog(
      barrierDismissible: false,
      barrierColor: const Color(0xd9E6E1E5),
      context: context,
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 14),
              label != null
                  ? Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Graphik',
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
