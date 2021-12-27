import 'package:camera/camera.dart';
import '../models/authentication.dart';
import '../pages/profile_page.dart';
import '../pages/sign_in.dart';
import '../pages/gallery.dart';
import '../utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/take_picture.dart';
import '../pages/gallery.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _AppRouterState createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _selectedIndex = 0;

  final List<Widget> _pagesWidget = [];

  final int GALLERY_PAGE_INDEX = 0;
  final int CAMERA_PAGE_INDEX = 1;
  final int ACCOUNT_PAGE_INDEX = 2;

  @override
  void initState() {
    super.initState();

    _pagesWidget.insert(GALLERY_PAGE_INDEX, const Gallery());
    _pagesWidget.insert(CAMERA_PAGE_INDEX, TakePicture(camera: widget.camera));
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
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Gallerie',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.filter_center_focus,
                    size: 32,
                  ),
                  backgroundColor: ColorUtils.gold,
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
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
