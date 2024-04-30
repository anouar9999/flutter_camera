import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_app_ai/trash/camera.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Obtain a list of the available cameras on the device
  final cameras = await availableCameras();

  // Get the first camera from the list of available cameras
  final firstCamera = cameras.first;

  runApp(MyApp(cameras: cameras));
}



