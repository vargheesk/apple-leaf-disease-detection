import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:io';

void main() {
  // Initialize Gemini before running the app
  Gemini.init(apiKey: "YOUR API KEY");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF0E6FF),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini _gemini = Gemini.instance; // Access Gemini instance directly
  File? _image;
  String? _result;
  String _prevention = '';
  String _cure = '';
  final _imagePicker = ImagePicker();
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    try {
      String labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.split(' ').sublist(1).join(' '))
          .toList();

      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      setState(() {});
    } catch (e) {
      // ignore: avoid_print
      print('Error loading model: $e');
    }
  }

  Future<void> getPreventionAndCure(String disease) async {
    try {
      // Get prevention information
      // ignore: deprecated_member_use
      var preventionResponse = await _gemini.text(
        '''Given the plant disease "$disease", provide prevention methods in 3-4 concise bullet points.
        Keep the response short and practical.''',
      );

      // Get cure information
      // ignore: deprecated_member_use
      var cureResponse = await _gemini.text(
        '''Given the plant disease "$disease", provide treatment/cure methods in 3-4 concise bullet points.
        Keep the response short and practical.''',
      );

      setState(() {
        _prevention = preventionResponse?.output ??
            'Unable to get prevention information';
        _cure = cureResponse?.output ?? 'Unable to get cure information';
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading model: $e');
      // setState(() {
      //   _prevention = 'Error fetching prevention information';
      //   _cure = 'Error fetching cure information';
      // });
    }
  }

  Future<void> classifyImage(File image) async {
    try {
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      if (imageInput == null) return;

      img.Image resizedImg =
          img.copyResize(imageInput, width: 224, height: 224);

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

      var outputArray = List.filled(4, 0.0).reshape([1, 4]);
      _interpreter.run([inputArray], outputArray);

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
      });

      // Get prevention and cure information after disease detection
      await getPreventionAndCure(_result!);
    } catch (e) {
      // ignore: avoid_print
      print('Error classifying image: $e');
      setState(() {
        _result = 'Error classifying image';
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _image = File(image.path);
        _prevention = '';
        _cure = '';
      });

      await classifyImage(_image!);
    } catch (e) {
      // ignore: avoid_print
      print("Error picking image: $e");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_image == null)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: Colors.white,
                                size: 50,
                              ),
                              Text(
                                'UPLOAD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Image.file(_image!, height: 200, fit: BoxFit.cover),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Plant        : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_result?.split('-')[0] ?? 'No plant detected'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Condition : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_result?.split('-')[1].replaceAll('_', ' ') ??
                            'Unknown'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          onPressed: () => pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 180, 157, 247),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          onPressed: () => pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 180, 157, 247),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DEF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prevention:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_prevention),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DEF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cure:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_cure),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
