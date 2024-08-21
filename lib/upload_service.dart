import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> uploadVideo(File video) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://10.0.2.2:3000/detect'),
  );
  request.files.add(await http.MultipartFile.fromPath('video', video.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await http.Response.fromStream(response);
    var jsonData = json.decode(responseData.body);
    return {
      'output': jsonData['output'],
      'confidence': jsonData['confidence'],
    };
  } else {
    return {
      'output': 'Error',
      'confidence': 0.0,
    };
  }
}
