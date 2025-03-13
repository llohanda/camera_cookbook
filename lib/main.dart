import 'package:camera/camera.dart';
import 'package:camera_cookbook/screens/take_picture.dart';
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
