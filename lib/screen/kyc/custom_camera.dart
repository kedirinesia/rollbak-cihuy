// @dart=2.9

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CustomCameraScreen extends StatefulWidget {
  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController controller;
  List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        controller.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
        }).catchError((error) {
          print('Error initializing camera: $error');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomPaint(
            foregroundPainter: Paint(),
            child: CameraPreview(controller),
          ),
          ClipPath(clipper: Clip(), child: CameraPreview(controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () => _takePicture(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _takePicture(BuildContext context) async {
    if (controller.value.isInitialized) {
      XFile xfile = await controller.takePicture();
      img.Image capturedImage =
          img.decodeImage(File(xfile.path).readAsBytesSync());

      final ktpRatio = 8.6 / 5.4; // Rasio KTP
      final double width =
          capturedImage.width - 20.0; // Mengurangi 10.0 dari masing-masing sisi
      final double height = width / ktpRatio;

      final double offsetX = 10.0; // Posisi awal X
      final double offsetY = (capturedImage.height - height) /
          2.0; // Posisi Y agar berada di tengah

      img.Image croppedImage = img.copyCrop(
        capturedImage,
        offsetX.toInt(),
        offsetY.toInt(),
        width.toInt(),
        height.toInt(),
      );

      final croppedFilePath = xfile.path.replaceFirst('.jpg', '_cropped.jpg');
      File(croppedFilePath)..writeAsBytesSync(img.encodeJpg(croppedImage));

      Navigator.pop(context, File(croppedFilePath));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class Paint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.5), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final ktpRatio = 8.6 / 5.4; // Rasio KTP
    final double width =
        size.width - 20.0; // Mengurangi 10.0 dari masing-masing sisi
    final double height = width / ktpRatio;

    final double offsetX = 10.0; // Posisi awal X
    final double offsetY =
        (size.height - height) / 2.0; // Posisi Y agar berada di tengah

    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(offsetX, offsetY, width, height),
          Radius.circular(26.0)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}
