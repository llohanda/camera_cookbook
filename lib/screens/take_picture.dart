import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_cookbook/screens/display_picture.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    this.title = 'Camera Demo Home Page',
  });

  final CameraDescription camera;
  final String title;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<String> images = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    // Display the camera's output with a controller
    _controller = CameraController(
      // Get the specific camera
      widget.camera,
      // Define the resolution to use. This one is 2160p.
      ResolutionPreset.veryHigh,
    );
    // Initialize the controller
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose controller when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else if (snapshot.hasError) {
                  return Text('Error initializing camera');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Ink(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    iconSize: 50.0,
                    onPressed: () async {
                      // Try taking pictures and handle any error
                      try {
                        // Ensure the camera is initialized
                        await _initializeControllerFuture;
                        // Take a picture and get the file's location
                        final image = await _controller.takePicture();
                        setState(() {
                          images.add(image.path);
                        });
                        if (context.mounted) {
                          final snackBar = SnackBar(
                            content: Text('Took an image: ${image.path}'),
                            duration: Duration(milliseconds: 500),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        // if (!context.mounted) return;
                        // // Display the picture on the next screen
                        // await Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder:
                        //         (context) => DisplayPictureScreen(
                        //           // Pass the automatically generated path to the display widget
                        //           imagePath: image.path,
                        //         ),
                        //   ),
                        // );
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10.0,
          left: 10.0,
          child: ImagePreviewButton(images: images),
        ),
      ],
    );
  }
}

class ImagePreviewButton extends StatelessWidget {
  const ImagePreviewButton({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return SizedBox();
    } else {
      return Badge.count(
        count: images.length,
        child: InkWell(
          child: Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(width: 4.0),
              image: DecorationImage(
                image: FileImage(File(images.last)),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          onTap: () async {
            if (!context.mounted) return;
            // Display the picture on the next screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to the display widget
                      imagePath: images.last,
                    ),
              ),
            );
          },
        ),
      );
    }
  }
}
