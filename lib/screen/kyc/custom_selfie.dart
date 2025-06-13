// @dart=2.9

import 'dart:io';
import 'dart:ui';
// import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

class CustomSelfieScreen extends StatefulWidget {
  @override
  _CustomSelfieScreenState createState() => _CustomSelfieScreenState();
}

class _CustomSelfieScreenState extends State<CustomSelfieScreen> {
  CameraController controller;
  List<CameraDescription> cameras;

  @override
  CameraDescription findFrontCamera(List<CameraDescription> cameras) {
    for (CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        return camera;
      }
    }
    return null; // Jika tidak ada kamera depan yang ditemukan
  }

  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      CameraDescription frontCamera = findFrontCamera(cameras);
      if (frontCamera != null) {
        controller = CameraController(frontCamera, ResolutionPreset.medium);
        controller.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
        });
      } else {
        print("Kamera depan tidak ditemukan!");
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
            foregroundPainter: MaskPainter(),
            child: CameraPreview(controller),
          ),
          ClipPath(clipper: SelfieClip(), child: CameraPreview(controller)),
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
      File file = File(xfile.path);

      Navigator.pop(context, file);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.5), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SelfieClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double ovalWidth = size.width * 0.4;
    final double ovalHeight = size.width * 0.5;

    final double rectWidth = size.width * 0.80;
    final double rectHeight = size.width * 0.80 * (50.98 / 80.6);

    final double spaceBetween = 50;

    final double ovalOffsetY =
        (size.height - ovalHeight - rectHeight - spaceBetween) / 2;
    final double rectOffsetY = ovalOffsetY + ovalHeight + spaceBetween;

    Path path = Path()
      // Oval
      ..addOval(Rect.fromLTWH(
          (size.width - ovalWidth) / 2, ovalOffsetY, ovalWidth, ovalHeight))
      // Rect
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
              (size.width - rectWidth) / 2, rectOffsetY, rectWidth, rectHeight),
          Radius.circular(26.0)));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
