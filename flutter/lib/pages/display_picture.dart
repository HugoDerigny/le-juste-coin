import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/analyze.dart';
import '../pages/full_image.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class AnalyzePicture extends StatefulWidget {
  final String imagePath;

  const AnalyzePicture({Key? key, required this.imagePath}) : super(key: key);

  @override
  _AnalyzePictureState createState() => _AnalyzePictureState();
}

class _AnalyzePictureState extends State<AnalyzePicture> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  late Future<Analyze> analyze;

  Future<Analyze> sendToApiForPrediction() async {
    String predictionEndpoint = dotenv.env['API_URL']! + '/analyses';

    final response = await http.post(Uri.parse(predictionEndpoint), headers: {
      'Authorization': auth.currentUser!.uid,
      'Content-Type': 'multipart/form-data'
    });

    if (response.statusCode == 201) {
      analyze = Analyze.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Une erreur est survenue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorUtils.blue,
          title: const Text('Analyser'),
        ),
        body: ListView(padding: EdgeInsets.all(12), children: [
    Align(
    alignment: Alignment.topLeft,
    child: Container(
    height: MediaQuery.of(context).size.height / 2,
    child: ListView(scrollDirection: Axis.horizontal,children: [
    GestureDetector(
    onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
    return FullImage(imagePath: imagePath);
    }));
    },
    child:  ClipRRect(
    borderRadius: BorderRadius.circular(12.0),
    child: Image.file(File(imagePath)),
    ),
    ),
    SizedBox(width: 8),
    FutureBuilder<Analyze>(
    future: analyze,
    builder: (BuildContext context, AsyncSnapshot<Analyze> analyze) {
    if (analyze.hasData) {

    } else {
    return Center(child: Text('Les images traitées vont appaîtres ici', style: FontUtils.content))
    }
    },
  }
  ])),
  ),
  ElevatedButton(
  style: ElevatedButton.styleFrom(
  primary: ColorUtils.blue,
  minimumSize: Size(double.infinity, 36),
  shape: new RoundedRectangleBorder(
  borderRadius: new BorderRadius.circular(12.0),
  )),
  onPressed: sendToApiForPrediction,
  child: const Text("Démarrer"),
  ),
  ]));
}
}
