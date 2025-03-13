import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

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
