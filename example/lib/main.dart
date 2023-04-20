import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_qr/native_qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeQr = NativeQr();
  String? qrString;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NativeQrPlugin example app'),
        ),
        body: Container( alignment: Alignment.center,
          child: Column(children: [
            ElevatedButton(onPressed: () async {
              try {
                var result = await _nativeQr.get();
                setState(() {
                  qrString = result;
                });
              } catch(err) {
                setState(() {
                  qrString = err.toString();
                });
              }
            }, child: const Text("Scan"), ),
            Text(qrString ?? "No data")
          ],)
        ),
      ),
    );
  }
}
