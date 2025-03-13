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
