import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_juste_coin/models/analyze.dart';
import '../pages/profile_page.dart';
import '../pages/gallery.dart';
import '../utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/take_picture.dart';
import 'package:http/http.dart' as http;

class AppRouter extends StatefulWidget {
  const AppRouter({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _AppRouterState createState() => _AppRouterState();
}

/// router de l'application
class _AppRouterState extends State<AppRouter> {
  int _selectedIndex = 0;
  late Future<List<Analyze>> _analyses;

  /// index de nos pages
  static const galleryPageIndex = 0;
  static const cameraPageIndex = 1;
  static const accountPageIndex = 2;

  /// récupère et met dans l'état global les analyses de l'utilisateur
  Future<List<Analyze>> setUserAnalyzes() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String analyzesEndpoint = dotenv.env['API_URL']! + '/analyse';

    final response = await http.get(Uri.parse(analyzesEndpoint), headers: {'Authorization': auth.currentUser!.uid});

    if (response.statusCode == 200) {
      List<dynamic> analyzesDto = jsonDecode(response.body);

      return analyzesDto.map((analyzeDto) => Analyze.fromJson(analyzeDto)).toList();
    } else {
      throw Exception('Une erreur est survenue.');
    }
  }

  /// met à jour les analyses de l'utilisateur
  void refreshAnalyzes() {
    setState(() {
      _analyses = setUserAnalyzes();
    });
  }

  /// à l'initialisation, récupère les analyses et déifinit les composants liés aux pages
  @override
  void initState() {
    super.initState();

    setState(() {
      _analyses = setUserAnalyzes();
    });
  }

  /// lorsqu'un onglet de la bottom navigation bar est tapé, cela met à jour l'index
  /// sélectionné, ou bien s'il s'agit de la camera, le pousse dans une nouvelle
  /// page
  void _onItemTapped(int index) {
    if (index == cameraPageIndex) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => TakePicture(camera: widget.camera, refreshAnalyzes: refreshAnalyzes)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: SafeArea(
              child: (() {
                switch(_selectedIndex) {
                  case galleryPageIndex:
                    return Gallery(setAnalyzes: refreshAnalyzes, analyzes: _analyses);

                  case cameraPageIndex:
                    return TakePicture(camera: widget.camera, refreshAnalyzes: refreshAnalyzes);

                  case accountPageIndex:
                    return ProfilePage(camera: widget.camera);

                  default:
                    return TakePicture(camera: widget.camera, refreshAnalyzes: refreshAnalyzes);
                }
              })()
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
