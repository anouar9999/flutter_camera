// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:web_app_ai/trash/Third_camera_screen.dart';


class second_camera_screen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const second_camera_screen({super.key, required this.cameras});

  @override
  State<second_camera_screen> createState() => _second_camera_screenState();
}

class _second_camera_screenState extends State<second_camera_screen> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<File> imagesList = [];
  bool isFlashOn = false;
  bool isRearCamera = true;

  Future<File> saveImage(XFile image) async {
    final downlaodPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downlaodPath/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (_) {}

    return file;
  }

  void takePicture() async {
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
    MaterialPageRoute(builder: (context) =>  Third_camera_screen(cameras: cameras,)),
  );

    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }

    final file = await saveImage(image);
    setState(() {
      imagesList.add(file);
    });
    MediaScanner.loadMedia(path: file.path);
  }

  void startCamera(int camera) {
    cameraController = CameraController(
      widget.cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(255, 255, 255, .7),
          
          shape: const CircleBorder(),
          onPressed: takePicture,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Container(),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                 width: size.width * 0.83,
                  height: size.height * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: 40.r),
                      child: SizedBox(
                        width: 100.w,
                        child:ClipRRect(
                            borderRadius: BorderRadius.circular(30.r),
                            child: CameraPreview(cameraController)),
                      ),
                    ),
                  ),
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
                        child:  Container(
                            width: 40.w,
                            height: 40.h,
                          )
                      ),
                    ),
                    const Gap(10),
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
                                      50.r), 
                                  child: Image.network(
                                    "https://scan.avaturn.me/assets/scan/final_side.png",
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
                          )),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
         Padding(
           padding: EdgeInsets.only(top: 45.r),
           child:  Align(
               alignment: Alignment.topCenter,
               child:  Row(
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
                          SizedBox(width: 2.w,),
                   const Text(
                     'Look Left to the Camera',
                     style: TextStyle(
                         color: Colors.amber,
                         fontSize: 16,
                         fontWeight: FontWeight.bold),
                   ),
                 ],
               )
               
               ),
         ),
        ],
      ),
    );
  }
}
