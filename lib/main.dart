import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  debugPrint('From these cameras: $cameras, we choose $firstCamera.');

  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}

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
  int _counter = 0;

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
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Try taking pictures and handle any error
          try {
            // Ensure the camera is initialized
            await _initializeControllerFuture;
            // Take a picture and get the file's location
            final image = await _controller.takePicture();

            if (!context.mounted) return;
            // Display the picture on the next screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to the display widget
                      imagePath: image.path,
                    ),
              ),
            );
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

enum GalExceptionType {
  accessDenied,
  notEnoughSpace,
  notSupportedFormat,
  unexpected;

  String get message => switch (this) {
    accessDenied => 'You do not have permission to access the gallery app.',
    notEnoughSpace => 'Not enough space for storage.',
    notSupportedFormat => 'Unsupported file formats.',
    unexpected => 'An unexpected error has occurred.',
  };
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Display the Picture'),
      ),
      body: Center(child: Image.file(File(imagePath))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await Gal.putImage(imagePath);
            if (context.mounted) {
              final snackBar = SnackBar(
                content: Text('Image saved'),
                action: SnackBarAction(
                  label: 'Open Gallery',
                  onPressed: () async => Gal.open(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } on GalException catch (e) {
            if (context.mounted) {
              final snackBar = SnackBar(content: Text(e.type.message));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            debugPrint(e.type.message);
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.save_alt),
      ),
    );
  }
}
