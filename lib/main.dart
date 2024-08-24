import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage widget

void main() {
  runApp(DeepfakeDetectionApp());
}

class DeepfakeDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'check This Out',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Orbitron', // Use a sci-fi font like Orbitron
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Deepfake Detection'),
    );
  }
}
