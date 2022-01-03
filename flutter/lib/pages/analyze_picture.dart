import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:le_juste_coin/components/tag.dart';
import 'package:le_juste_coin/models/analyze_exception.dart';
import 'package:le_juste_coin/pages/gallery.dart';
import '../models/analyze.dart';
import '../pages/full_image.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';

class AnalyzePicture extends StatefulWidget {
  final String imagePath;
  final Function setAnalyzes;

  const AnalyzePicture({Key? key, required this.imagePath, required this.setAnalyzes }) : super(key: key);

  @override
  _AnalyzePictureState createState() => _AnalyzePictureState();
}

class _AnalyzePictureState extends State<AnalyzePicture> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var _analyze;

  Future<Analyze> _getAnalyzeOfImage() async {
    String predictionEndpoint = dotenv.env['API_URL']! + '/analyse';

    http.MultipartFile image = await http.MultipartFile.fromPath('image', widget.imagePath);

    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(predictionEndpoint));
    request.headers['Authorization'] = auth.currentUser!.uid;
    request.files.add(image);

    http.StreamedResponse response = await request.send();
    http.Response responseStream = await http.Response.fromStream(response);

    switch (response.statusCode) {
      case 201:
        return Analyze.fromJson(jsonDecode(responseStream.body));
      case 204:
        throw AnalyzeException.noCoinsFound();
      case 401:
        throw Exception('Vous devez être connecté afin de faire une analyze.');
      default:
        throw Exception(responseStream.body);
    }
  }

  Future<void> _sendForPrediction(BuildContext context) async {
    try {
      Analyze analyze = await _getAnalyzeOfImage();

      widget.setAnalyzes();

      setState(() {
        _analyze = analyze;
      });
    } catch (exception) {
      Color bgColor = exception is AnalyzeException ? ColorUtils.warning : ColorUtils.danger;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()), backgroundColor: bgColor));
    }
  }

  Color _getColorOnConfidence(int confidence) {
    Color ok = ColorUtils.success;
    Color average = ColorUtils.warning;
    Color bad = ColorUtils.danger;

    return confidence > 80
        ? ok
        : confidence > 40
            ? average
            : bad;
  }

  Widget _displayAnalyze(BuildContext context) {
    return ListView(padding: EdgeInsets.all(12), children: [
      Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: FutureBuilder(
                future: _analyze.getImagesInOrder(),
                builder: (BuildContext context, AsyncSnapshot<Map<String, String>> images) {
                  if (images.hasData) {
                    return ListView(scrollDirection: Axis.horizontal, children: [
                      ...images.data!.keys.map((imageType) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return FullImage(title: imageType, imagePath: images.data![imageType]!);
                              }));
                            },
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(images.data![imageType]!, fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                      padding: EdgeInsets.all(32),
                                      child: CircularProgressIndicator(
                                          color: ColorUtils.blue,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null));
                                })),
                          )))
                    ]);
                  } else {
                    return const CircularProgressIndicator(); // placeholder
                  }
                },
              ))),
      const SizedBox(height: 8),
      Text('${_analyze.id} - ${_analyze.getFullDateFormatted()}', style: FontUtils.content),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_analyze.getFormattedCoinsInEuros(), style: FontUtils.title),
        Tag(content: '${_analyze.averageConfidence}%', color: _getColorOnConfidence(_analyze.averageConfidence))
      ]),
      const SizedBox(height: 24),
      Text('Détails des analyses', style: FontUtils.header),
      ..._analyze.items
          .map(
            (item) => Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: ColorUtils.gray,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: FutureBuilder(
                          future: item.getImageUrl(),
                          builder: (BuildContext context, AsyncSnapshot<String> image) {
                            if (image.hasData) {
                              return Image.network(image.data!, fit: BoxFit.fill, width: 48, height: 48); // image is ready
                            } else {
                              return const CircularProgressIndicator(); // placeholder
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.getFormattedCoinInEuros(), style: FontUtils.header)
                    ]),
                    Tag(content: '${item.confidence}%', color: _getColorOnConfidence(item.confidence))
                  ],
                )),
          )
          .toList(),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: ColorUtils.success,
            minimumSize: Size(double.infinity, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("OK"),
      )
    ]);
  }

  Widget _displayWaitingForAnalyze(BuildContext context) {
    return ListView(padding: EdgeInsets.all(12), children: [
      Align(
        alignment: Alignment.topLeft,
        child: Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Container(
                child: ListView(scrollDirection: Axis.horizontal, children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FullImage(imagePath: widget.imagePath);
                  }));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(File(widget.imagePath)),
                ),
              ),
              Center(child: Text('Les images traitées vont appaîtres ici', style: FontUtils.content))
            ]))),
      ),
      SizedBox(height: 8),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: ColorUtils.blue,
            minimumSize: Size(double.infinity, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )),
        onPressed: () {
          _sendForPrediction(context);
        },
        child: const Text("Démarrer"),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorUtils.blue,
          title: const Text('Analyser'),
        ),
        body: _analyze is Analyze ? _displayAnalyze(context) : _displayWaitingForAnalyze(context));
  }
}
