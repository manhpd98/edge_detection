import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';
import 'screens/gallery_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edge Detection Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge Detection Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text('Open Camera View'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GalleryScreen()),
                );
              },
              child: const Text('Open Gallery View'),
            ),
          ],
        ),
      ),
    );
  }
}

// class _MyAppState extends State<MyApp> {
//   String? _imagePath;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<void> getImageFromCamera() async {
//     bool isCameraGranted = await Permission.camera.request().isGranted;
//     if (!isCameraGranted) {
//       isCameraGranted =
//           await Permission.camera.request() == PermissionStatus.granted;
//     }
//
//     if (!isCameraGranted) {
//       // Have not permission to camera
//       return;
//     }
//
//     // Generate filepath for saving
//     String imagePath = join((await getApplicationSupportDirectory()).path,
//         "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
//
//     bool success = false;
//
//     try {
//       //Make sure to await the call to detectEdge.
//       success = await EdgeDetection.detectEdge(
//         imagePath,
//         canUseGallery: true,
//         androidScanTitle: 'Scanning', // use custom localizations for android
//         androidCropTitle: 'Crop',
//         androidCropBlackWhiteTitle: 'Black White',
//         androidCropReset: 'Reset',
//       );
//       print("success: $success");
//     } catch (e) {
//       print(e);
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     setState(() {
//       if (success) {
//         _imagePath = imagePath;
//       }
//     });
//   }
//
//   Future<void> getImageFromGallery() async {
//     // Generate filepath for saving
//     String imagePath = join((await getApplicationSupportDirectory()).path,
//         "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
//
//     bool success = false;
//     try {
//       //Make sure to await the call to detectEdgeFromGallery.
//       success = await EdgeDetection.detectEdgeFromGallery(
//         imagePath,
//         androidCropTitle: 'Crop', // use custom localizations for android
//         androidCropBlackWhiteTitle: 'Black White',
//         androidCropReset: 'Reset',
//       );
//       print("success: $success");
//     } catch (e) {
//       print(e);
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     setState(() {
//       if (success) {
//         _imagePath = imagePath;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child: ElevatedButton(
//                   onPressed: getImageFromCamera,
//                   child: Text('Scan'),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: getImageFromGallery,
//                   child: Text('Upload'),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text('Cropped image path:'),
//               Padding(
//                 padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
//                 child: Text(
//                   _imagePath.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14),
//                 ),
//               ),
//               Visibility(
//                 visible: _imagePath != null,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Image.file(
//                     File(_imagePath ?? ''),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
