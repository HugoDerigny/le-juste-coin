import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/gallery_item.dart';
import '../models/analyze.dart';
import '../utils/font_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<Analyze>> analyzes;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<List<Analyze>> _getUserAnalyzes() async {
    String analyzesEndpoint = dotenv.env['API_URL']! + '/analyses';

    final response = await http.get(Uri.parse(analyzesEndpoint), headers: {
      'Authorization': auth.currentUser!.uid
    });

    if (response.statusCode == 200) {
      List<dynamic> analyzesDto = jsonDecode(response.body);

      return analyzesDto.map((analyzeDto) => Analyze.fromJson(analyzeDto)).toList();
    } else {
      throw Exception('Une erreur est survenue.');
    }
  }

  @override
  void initState() {
    try {
      analyzes = _getUserAnalyzes();
    } catch (e) {
      // Show error toast
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gallerie', style: FontUtils.title),
            FutureBuilder<List<Analyze>>(
              future: analyzes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.only(top: 16),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      children: [
                        ...snapshot.data!.map((analyze) => GalleryItem(analyze: analyze)).toList()
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            )
          ]
      ),
    );
  }
}