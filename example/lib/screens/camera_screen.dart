import 'dart:io';

import 'package:edge_detection/edge_detection_view.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: EdgeDetectionView(
              canUseGallery: true,
              onImageCaptured: (String imagePath) {
                setState(() {
                  _imagePath = imagePath;
                });
              },
              onError: (String error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              },
              onCancel: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scanning cancelled')),
                );
              },
            ),
          ),
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_imagePath!),
                height: 200,
              ),
            ),
        ],
      ),
    );
  }
}
