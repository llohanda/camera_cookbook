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
