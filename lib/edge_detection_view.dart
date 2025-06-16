import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeDetectionView extends StatefulWidget {
  final bool canUseGallery;
  final Function(String) onImageCaptured;
  final Function(String)? onError;
  final VoidCallback? onCancel;

  const EdgeDetectionView({
    Key? key,
    this.canUseGallery = true,
    required this.onImageCaptured,
    this.onError,
    this.onCancel,
  }) : super(key: key);

  @override
  State<EdgeDetectionView> createState() => _EdgeDetectionViewState();
}

class _EdgeDetectionViewState extends State<EdgeDetectionView> {
  static const viewType = 'edge_detection_view';
  late MethodChannel _channel;
  int _viewId = 0;

  @override
  void initState() {
    super.initState();
    _viewId = DateTime.now().millisecondsSinceEpoch;
    _channel = MethodChannel('edge_detection_view_$_viewId');
    print('Flutter channel name: edge_detection_view_$_viewId');
    _setupChannel();
  }

  void _setupChannel() {
    print('Setting up Flutter method channel handler');
    _channel.setMethodCallHandler((call) async {
      print('Flutter received method call: ${call.method}');
      switch (call.method) {
        case 'onImageCaptured':
          final String imagePath = call.arguments as String;
          widget.onImageCaptured(imagePath);
          break;
        case 'onError':
          final String error = call.arguments as String;
          widget.onError?.call(error);
          break;
        case 'onCancel':
          widget.onCancel?.call();
          break;
        case 'onResult':
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: {
          'can_use_gallery': widget.canUseGallery,
          'view_id': _viewId,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          // View đã được tạo
        },
      );
    }
    return const Center(
      child: Text('Platform not supported'),
    );
  }
}
