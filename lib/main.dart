import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DeepfakeDetectionApp());
}

class DeepfakeDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Deepfake Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  File? _selectedVideo;
  String _output = '';
  double _confidence = 0.0;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    
    if (result != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/detect'),
    );
    request.files.add(await http.MultipartFile.fromPath('video', _selectedVideo!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var jsonData = json.decode(responseData.body);
      
      setState(() {
        _output = jsonData['output'];
        _confidence = jsonData['confidence'];
      });
    } else {
      setState(() {
        _output = 'Error';
        _confidence = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick Video'),
            ),
            SizedBox(height: 20),
            _selectedVideo != null
                ? Text('Selected video: ${_selectedVideo!.path}')
                : Text('No video selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadVideo,
              child: Text('Upload and Detect'),
            ),
            SizedBox(height: 20),
            Text('Output: $_output'),
            Text('Confidence: ${_confidence.toStringAsFixed(2)}%'),
          ],
        ),
      ),
    );
  }
}
