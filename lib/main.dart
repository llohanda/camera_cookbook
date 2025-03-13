import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
      home: TakePicturePage(camera: firstCamera),
    ),
  );
}

class TakePicturePage extends StatefulWidget {
  const TakePicturePage({
    super.key,
    required this.camera,
    this.title = 'Camera Demo Home Page',
  });

  final CameraDescription camera;
  final String title;

  @override
  State<TakePicturePage> createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
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
    );
  }
}
