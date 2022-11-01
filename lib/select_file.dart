import 'package:flutter/cupertino.dart';

enum FileTypeSelect {
  gallery,
  file,
  camera,
}

class SelectFileOptions {
  static show(
      {required BuildContext context, required List<FileTypeSelect> types}) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Add a File'),
        message: const Text('Choose a file from your device'),
        actions: [
          if (types.contains(FileTypeSelect.gallery))
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context, FileTypeSelect.gallery);
              },
            ),
          if (types.contains(FileTypeSelect.camera))
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context, FileTypeSelect.camera);
              },
            ),
          if (types.contains(FileTypeSelect.file))
            CupertinoActionSheetAction(
              child: const Text('Phone Library'),
              onPressed: () {
                Navigator.pop(context, FileTypeSelect.file);
              },
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
