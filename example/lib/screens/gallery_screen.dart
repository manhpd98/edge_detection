import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edge_detection/edge_detection.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _imagePath;

  Future<void> getImageFromGallery() async {
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;
    try {
      success = await EdgeDetection.detectEdgeFromGallery(
        imagePath,
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      if (success) {
        _imagePath = imagePath;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery View'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: getImageFromGallery,
              child: const Text('Select from Gallery'),
            ),
          ),
          const SizedBox(height: 20),
          if (_imagePath != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 