import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:web_app_ai/trash/second_camera_screen.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize screen util for responsive UI design
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(cameras: cameras),
    );
  }
}



class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<XFile> imagesList = [];
  bool isFlashOn = false;
  bool isRearCamera = true;

  Future<void> saveImage(XFile image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downloadPath/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (_) {}

    setState(() {
      imagesList.add(file as XFile);
    });
  }

  Future<void> takePicture() async {
    XFile? image;

    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }

    if (isFlashOn == false) {
      await cameraController.setFlashMode(FlashMode.off);
    } else {
      await cameraController.setFlashMode(FlashMode.torch);
    }
    image = await cameraController.takePicture();

    final cameras = await availableCameras();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => second_camera_screen(cameras: cameras)),
    );

    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }

    await saveImage(image);
  }

  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  void initState() {
    super.initState();
    startCamera(0);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: SizedBox(
        height: 70.h,
        width: 70.w,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: const Color.fromRGBO(255, 255, 255, .7),
            child: Container(),
            onPressed: takePicture,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<void>(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final size = MediaQuery.of(context).size;
                return SizedBox(
                  width: size.width,
                  height: size.width / cameraController.value.aspectRatio,
                  child: Container()
                  // CameraPreview(cameraController),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(50, 0, 0, 0),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRearCamera = !isRearCamera;
                        });
                        isRearCamera ? startCamera(0) : startCamera(1);
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    50.r), // Adjust the value as needed
                                child: Image.network(
                                  "https://scan.avaturn.me/assets/scan/final_front.png",
                                  width: 100.w,
                                  height: 100.h,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 50.r),
                                child: CircleAvatar(
                                  backgroundColor: Colors.amber,
                                  radius: 15,
                                  child: Icon(
                                    Icons.warning_amber,
                                    color: Colors.white,
                                    size: 15.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 45.r),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 15,
                    child: Icon(
                      Icons.warning_amber,
                      color: Colors.amber,
                      size: 15.h,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'Look Right to the Camera.....please',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

