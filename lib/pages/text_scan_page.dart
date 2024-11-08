import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

class TextScanPage extends StatefulWidget {
  const TextScanPage({super.key, required this.title});

  final String title;

  @override
  State<TextScanPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TextScanPage> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();
  bool torchOn = false;
  int cameraSelection = 0;
  bool lockCamera = true;
  bool loading = false;
  final GlobalKey<ScalableOCRState> cameraKey = GlobalKey<ScalableOCRState>();

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
                      key: cameraKey,
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
                  return Result(
                      text: snapshot.data != null ? snapshot.data! : "");
                },
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                          cameraSelection = cameraSelection == 0 ? 1 : 0;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      },
                      child: const Text("Switch Camera")),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                          torchOn = !torchOn;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      },
                      child: const Text("Toggle Torch")),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                          lockCamera = !lockCamera;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      },
                      child: const Text("Toggle Lock Camera")),
                ],
              )
            ],
          ),
        ));
  }
}

class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text("Readed text: $text");
  }
}
