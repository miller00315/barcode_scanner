import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;

  late ImagePicker _imagePicker;

  late BarcodeScanner _barcodeScanner;

  List<Barcode>? _barCodes;

  @override
  void initState() {
    _imagePicker = ImagePicker();

    final List<BarcodeFormat> formats = [BarcodeFormat.all];

    _barcodeScanner = BarcodeScanner(formats: formats);

    super.initState();
  }

  _getImageFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

      doBarCodeScanner();
    }
  }

  _getImageFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

      doBarCodeScanner();
    }
  }

  doBarCodeScanner() async {
    if (_image != null) {
      final InputImage inputImage = InputImage.fromFile(_image!);

      final barCodes = await _barcodeScanner.processImage(inputImage);

      setState(() {
        _barCodes = barCodes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.fill,
                    )
                  : const Icon(
                      Icons.camera,
                      size: 100,
                    ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _getImageFromGallery,
                      onLongPress: _getImageFromCamera,
                      child: const Text('Get image'),
                    ),
                    const SizedBox(height: 16),
                    if (_barCodes != null)
                      ..._barCodes!.map(
                        (barCode) {
                          switch (barCode.type) {
                            case BarcodeType.url:
                              BarcodeUrl barcodeUrl = barCode as BarcodeUrl;

                              return Text('${barcodeUrl.url}');

                            case BarcodeType.wifi:
                              BarcodeWifi barcodeWifi = barCode as BarcodeWifi;

                              return Text(
                                '${barcodeWifi.ssid} ${barcodeWifi.password}',
                              );

                            default:
                              return const Text('Unknown');
                          }
                        },
                      ).toList()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
