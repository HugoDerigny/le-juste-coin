import '../utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import './analyze_picture.dart';

class TakePicture extends StatefulWidget {
  final CameraDescription camera;
  final Function refreshAnalyzes;

  const TakePicture({
    Key? key,
    required this.camera,
    required this.refreshAnalyzes
  }) : super(key: key);

  @override
  TakePictureState createState() => TakePictureState();
}

/// page qui utilise la caméra pour prendre en photo les pièces,
/// une fois la photo prise cela amène sur la page [analyse_picture.dart]
class TakePictureState extends State<TakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  FlashMode _flashMode = FlashMode.off;

  /// initialise la caméra à la meilleure résolution
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _controller.setFlashMode(_flashMode);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compter mes pièces'),
        backgroundColor: ColorUtils.pureBlack,
      ),
      body: Stack(alignment: FractionalOffset.center, children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Positioned.fill(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller)),
            );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(64),
              child:Opacity(
                opacity: 0.4,
                child: Image.asset(
                  'assets/images/overlay.png',
                  fit: BoxFit.contain,
                ),
              )
            ),
        )
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton(
          backgroundColor: ColorUtils.white,
          onPressed: () async {
            setState(() {
              _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
            });
            _controller.setFlashMode(_flashMode);
          },
          child: Icon(_flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on, color: ColorUtils.gold),
        ),
        SizedBox(width: 8),
        FloatingActionButton(
          backgroundColor: ColorUtils.gold,
          onPressed: () async {
            try {
              await _initializeControllerFuture;

              final image = await _controller.takePicture();

              Navigator.pop(context);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnalyzePicture(
                      imagePath: image.path, refreshAnalyzes: widget.refreshAnalyzes
                  ),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera),
        ),
      ])
    );
  }
}
