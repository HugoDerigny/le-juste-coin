import '../utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'display_picture.dart';

// A screen that allows users to take a picture using a given camera.
class TakePicture extends StatefulWidget {
  const TakePicture({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

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
        backgroundColor: ColorUtils.blue,
        title: Text('Effectuer une analyse'),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorUtils.gold,
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
