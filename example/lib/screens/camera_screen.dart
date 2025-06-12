import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edge_detection/edge_detection_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? _imagePath;

  Future<String> _getImagePath() async {
    return join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera View'),
      ),
      body: FutureBuilder<String>(
        future: _getImagePath(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: EdgeDetectionView(
                  saveTo: snapshot.data!,
                  canUseGallery: true,
                  onResult: (bool success) {
                    if (success) {
                      setState(() {
                        _imagePath = snapshot.data;
                      });
                    }
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
          );
        },
      ),
    );
  }
} 