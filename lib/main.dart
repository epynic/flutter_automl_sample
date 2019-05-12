import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'QuizApp Solver'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool predictionStarted = false;
  bool predictionComplete = false;
  var predictionResult = 'Please wait....';

  Future getImage() async {
    setState(() {
      predictionStarted = false;
      predictionComplete = false;
    });

    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      predictionStarted = true;
    });

    //post image
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);

    print(base64Image);

    Map<String, String> headers = {"Accept": "application/json"};
    Map body = {"image": base64Image};

    var response = await http.post('http://35.237.157.131/automl.php',
        body: body, headers: headers);

    setState(() {
      predictionResult = response.body;
      predictionComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              'Push the camera button',
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              onPressed: getImage,
              child: Text('Camera'),
            ),
            (_image != null)
                ? Image.file(
                    _image,
                    scale: 20,
                  )
                : Text('No Image Picked'),
            predictionBody()
          ],
        ),
      ),
    );
  }

  Widget predictionBody() {
    var predictionText = (predictionComplete) ? 'Result' : 'Prediction started';
    if (predictionStarted) {
      return Column(
        children: <Widget>[
          Divider(),
          Text(predictionText),
          Text(predictionResult)
        ],
      );
    } else {
      return Container();
    }
  }
}
