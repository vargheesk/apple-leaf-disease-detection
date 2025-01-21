// main.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  File? _image;
  String? _result;
  final _imagePicker = ImagePicker();
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel();
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    try {
      // Load labels
      String labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.split(' ').sublist(1).join(' '))
          .toList();

      // Load model
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> classifyImage(File image) async {
    try {
      // Decode and resize image
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      if (imageInput == null) return;

      img.Image resizedImg =
          img.copyResize(imageInput, width: 224, height: 224);

      // Convert image to float32 array
      var inputArray = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImg.getPixel(x, y);
            return [
              (pixel.r.toDouble() - 127.5) / 127.5,
              (pixel.g.toDouble() - 127.5) / 127.5,
              (pixel.b.toDouble() - 127.5) / 127.5,
            ];
          },
        ),
      );

      // Run inference
      var outputArray = List.filled(4, 0.0).reshape([1, 4]);
      _interpreter.run([inputArray], outputArray);

      // Get prediction
      var maxIndex = 0;
      var maxValue = outputArray[0][0];
      for (var i = 1; i < outputArray[0].length; i++) {
        if (outputArray[0][i] > maxValue) {
          maxValue = outputArray[0][i];
          maxIndex = i;
        }
      }

      setState(() {
        _result = _labels[maxIndex];
        _loading = false;
      });
    } catch (e) {
      print('Error classifying image: $e');
      setState(() {
        _loading = false;
        _result = 'Error classifying image';
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _loading = true;
        _image = File(image.path);
      });

      await classifyImage(_image!);
    } catch (e) {
      print("Error picking image: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaf Disease Detector'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? const Text('No image selected.')
                      : Image.file(_image!, height: 300, fit: BoxFit.cover),
                  SizedBox(height: 20),
                  _result != null
                      ? Text(
                          'Disease: $_result',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Container(),
                  SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => pickImage(ImageSource.camera),
            tooltip: 'Take Photo',
            child: Icon(Icons.camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => pickImage(ImageSource.gallery),
            tooltip: 'Pick from Gallery',
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
