import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'upload_service.dart'; // Import the upload service

void main() {
  runApp(DeepfakeDetectionApp());
}

class DeepfakeDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake Detection',
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
  bool _isLoading = false;
  VideoPlayerController? _videoController;

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {}); // Update the UI to show the video player.
          });
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isLoading = true;
      _output = '';
      _confidence = 0.0;
    });

    final result = await uploadVideo(_selectedVideo!);

    setState(() {
      _output = result['output'];
      _confidence = result['confidence'];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.network(
                'https://media.giphy.com/media/26xBwdIuRJiAIqHwA/giphy.gif',
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: Icon(Icons.videocam, color: Colors.cyanAccent),
              label: Text('Pick Video'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.cyanAccent[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            _selectedVideo != null && _videoController!.value.isInitialized
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      SizedBox(height: 10),
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: const Color.fromARGB(255, 0, 229, 255),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 40,
                              color: Colors.cyanAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No video selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadVideo,
              icon: Icon(Icons.cloud_upload, color: Colors.cyanAccent),
              label: Text('Upload and Detect'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _output.isNotEmpty
                    ? Column(
                        children: [
                          Text(
                            'Output:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _output,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Confidence: ${_confidence.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      )
                    : Container(),
            SizedBox(height: 20),
            Center(
              child: Image.network(
                'https://media.giphy.com/media/l0HlBO7eyXzSZkJri/giphy.gif',
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
