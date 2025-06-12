import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeDetectionView extends StatefulWidget {
  final String saveTo;
  final bool canUseGallery;
  final Function(bool) onResult;

  const EdgeDetectionView({
    Key? key,
    required this.saveTo,
    this.canUseGallery = true,
    required this.onResult,
  }) : super(key: key);

  @override
  State<EdgeDetectionView> createState() => _EdgeDetectionViewState();
}

class _EdgeDetectionViewState extends State<EdgeDetectionView> {
  static const platform = MethodChannel('edge_detection');
  static const viewType = 'edge_detection_view';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: {
          'save_to': widget.saveTo,
          'can_use_gallery': widget.canUseGallery,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Center(
      child: Text('Platform not supported'),
    );
  }

  void _onPlatformViewCreated(int id) {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onResult':
          final bool result = call.arguments as bool;
          widget.onResult(result);
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }
} 