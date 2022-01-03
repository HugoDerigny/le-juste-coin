import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_juste_coin/models/analyze.dart';
import '../models/authentication.dart';
import '../pages/profile_page.dart';
import '../pages/sign_in.dart';
import '../pages/gallery.dart';
import '../utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/take_picture.dart';
import '../pages/gallery.dart';
import 'package:http/http.dart' as http;

class AppRouter extends StatefulWidget {
  const AppRouter({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _AppRouterState createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _selectedIndex = 0;
  late Future<List<Analyze>> _analyses;

  final List<Widget> _pagesWidget = [];

  final int GALLERY_PAGE_INDEX = 0;
  final int CAMERA_PAGE_INDEX = 1;
  final int ACCOUNT_PAGE_INDEX = 2;

  Future<List<Analyze>> setUserAnalyzes() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String analyzesEndpoint = dotenv.env['API_URL']! + '/analyse';

    final response = await http.get(Uri.parse(analyzesEndpoint), headers: {'Authorization': auth.currentUser!.uid});

    if (response.statusCode == 200) {
      List<dynamic> analyzesDto = jsonDecode(response.body);

      print('Fetched ' + analyzesDto.length.toString() + ' analyses');

      return analyzesDto.map((analyzeDto) => Analyze.fromJson(analyzeDto)).toList();
    } else {
      throw Exception('Une erreur est survenue.');
    }
  }

  void refreshAnalyzes() {
    setState(() {
      _analyses = setUserAnalyzes();
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _analyses = setUserAnalyzes();
    });

    _pagesWidget.insert(GALLERY_PAGE_INDEX, Gallery(setAnalyzes: refreshAnalyzes, analyzes: _analyses));
    _pagesWidget.insert(CAMERA_PAGE_INDEX, TakePicture(camera: widget.camera, setAnalyzes: refreshAnalyzes));
    _pagesWidget.insert(ACCOUNT_PAGE_INDEX, ProfilePage(camera: widget.camera));
  }

  void _onItemTapped(int index) {
    if (index == CAMERA_PAGE_INDEX) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => _pagesWidget[CAMERA_PAGE_INDEX]),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('rendering');
    return Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pagesWidget,
              )
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded, size: 20),
                  label: 'Gallerie',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.filter_center_focus,
                    size: 32,
                  ),
                  backgroundColor: ColorUtils.gold,
                  label: 'Analyzer',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 20),
                  label: 'Profil',
                ),
              ],
              currentIndex: _selectedIndex,
              backgroundColor: ColorUtils.blue,
              selectedItemColor: ColorUtils.gold,
              unselectedItemColor: ColorUtils.gray,
              iconSize: 20,
              unselectedFontSize: 12,
              selectedFontSize: 12,
              onTap: _onItemTapped,
            ),
          );
  }
}
