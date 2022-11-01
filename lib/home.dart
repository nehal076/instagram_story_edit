import 'dart:io';
import 'package:blup_task/loader.dart';
import 'package:blup_task/painter.dart';
import 'package:blup_task/select_file.dart';
import 'package:blup_task/write_text.dart';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:screenshot/screenshot.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? imageFile;
  String? text = '';
  Color? vibrantColor = Colors.white;
  Color? lightVibrantColor = Colors.white;
  bool showControls = true;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> save() async {
    try {
      Loader.show(context, "Saving your image...");
      setState(() {
        showControls = false;
      });

      var image = await screenshotController.capture();

      if (image != null) {
        setState(() {
          showControls = true;
        });

        var saved = await ImageGallerySaver.saveImage(
          image,
          quality: 100,
          name: "${DateTime.now().toIso8601String()}.png",
          isReturnImagePathOfIOS: true,
        );

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Image Saved Successfully"),
        ));

        print(saved);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: imageFile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/upload.json'),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: const Text('Upload Image'),
                  ),
                ],
              ),
            )
          : Screenshot(
              controller: screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      vibrantColor ?? Colors.black12,
                      lightVibrantColor ?? Colors.white
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Image.file(
                            imageFile!,
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Painter(
                          getText: (value) {
                            setState(() {
                              text = value;
                            });
                          },
                          onSave: save,
                          showControls: showControls,
                        ),
                        WriteText(text: text),
                      ],
                    ),
                    showControls == true
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40, right: 8),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    imageFile = null;
                                    text = '';
                                  });
                                },
                                icon: const Icon(Icons.close),
                                color: Colors.black,
                                iconSize: 32,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
    );
  }

  _uploadImage() async {
    FileTypeSelect? result = await SelectFileOptions.show(
      context: context,
      types: [
        FileTypeSelect.gallery,
        FileTypeSelect.camera,
      ],
    );
    if (result == null) return;
    if (result == FileTypeSelect.gallery) {
      _getImage(ImageSource.gallery);
    } else if (result == FileTypeSelect.camera) {
      _getImage(ImageSource.camera);
    }
  }

  _getImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });

      getImageColor(pickedFile.path);
    }
  }

  getImageColor(String img) async {
    var image = Image(image: FileImage(File(img))).image;
    vibrantColor = await getVibrantColor(image);
    lightVibrantColor = await getLightVibrantColor(image);

    setState(() {});
  }

  Future<Color?>? getVibrantColor(ImageProvider<Object> imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.lightVibrantColor?.color;
  }

  Future<Color?>? getLightVibrantColor(
      ImageProvider<Object> imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.darkVibrantColor?.color;
  }
}
