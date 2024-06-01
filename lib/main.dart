
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo rằng các camera đã được khởi tạo trước khi ứng dụng chạy
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(CameraApp(camera: firstCamera));
}

class CameraApp extends StatelessWidget {
  final CameraDescription camera;

  const CameraApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({required this.camera});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera App'),
      ),
      body: Center(
        child: _imageFile == null
            ? Text('No image captured.')
            : GestureDetector(onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_)=> imageView(image: _imageFile!))
              );
            }, child: Hero(tag:'image', child: Image.file(_imageFile!,), )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TakePictureScreen(camera: widget.camera),
            ),
          );

          if (image != null) {
            setState(() {
              _imageFile = image;
            });
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({required this.camera});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
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
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            Navigator.pop(context, File(image.path));
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


class imageView extends StatelessWidget {
  const imageView({super.key, required this.image,});
  final File image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), 
      body: Center(
        child: InteractiveViewer(panEnabled: false, boundaryMargin: EdgeInsets.all(100), maxScale: 2,child: Image.file(image))
    ),);
  }
}