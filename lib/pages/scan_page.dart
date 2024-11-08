import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String result = ''; // To hold the result (either barcode or text)
  bool loading = false;
  final StreamController<String> controller = StreamController<String>();

  bool torchOn = false;
  int cameraSelection = 0;
  bool lockCamera = true;

  // Function to start barcode scanning
  Future<void> scanBarcode() async {
    final scanResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleBarcodeScannerPage(),
      ),
    );

    // If a barcode is found, show the barcode result
    if (scanResult != null && scanResult.isNotEmpty) {
      setState(() {
        result = 'Barcode: $scanResult';
      });
    } else {
      // If no barcode is found, fallback to OCR to scan text
      await scanTextFromImage();
    }
  }

  // Function to perform OCR using Flutter Scalable OCR
  Future<void> scanTextFromImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        loading = true;
      });

      // Use OCR to scan text from the image
      final text = await scanTextFromFile(image.path);

      setState(() {
        loading = false;
        // If OCR text is empty, display a no text message
        result = text.isEmpty ? 'No text detected' : 'Text: $text';
      });
    }
  }

  // Function to scan text from file using ScalableOCR
  Future<String> scanTextFromFile(String imagePath) async {
    // final ocrText = await ScalableOCR.scanTextFromImage(imagePath);
    return 'No text ';
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode or Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Start Scan'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : Text(
                    result.isEmpty ? 'Scan result will appear here' : result,
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TextScanPage(title: 'Scan Text')),
                );
              },
              child: const Text('Start Text Scan Manually'),
            ),
          ],
        ),
      ),
    );
  }
}

// TextScanPage for OCR scanning functionality
class TextScanPage extends StatefulWidget {
  const TextScanPage({super.key, required this.title});

  final String title;

  @override
  State<TextScanPage> createState() => _TextScanPageState();
}

class _TextScanPageState extends State<TextScanPage> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();
  bool torchOn = false;
  int cameraSelection = 0;
  bool lockCamera = true;
  bool loading = false;

  void setText(value) {
    controller.add(value);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              !loading
                  ? ScalableOCR(
                      key: GlobalKey<ScalableOCRState>(),
                      torchOn: torchOn,
                      cameraSelection: cameraSelection,
                      lockCamera: lockCamera,
                      paintboxCustom: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4.0
                        ..color = const Color.fromARGB(153, 102, 160, 241),
                      boxLeftOff: 5,
                      boxBottomOff: 2.5,
                      boxRightOff: 5,
                      boxTopOff: 2.5,
                      boxHeight: MediaQuery.of(context).size.height / 3,
                      getRawData: (value) {
                        inspect(value);
                      },
                      getScannedText: (value) {
                        setText(value);
                      })
                  : Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
              StreamBuilder<String>(
                stream: controller.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Text(snapshot.data != null
                      ? 'Detected Text: ${snapshot.data!}'
                      : "No text detected");
                },
              ),
            ],
          ),
        ));
  }
}
