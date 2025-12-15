import 'package:flutter/material.dart';

import '../core/home_screen.dart';
import '../core/gallery/all_gallery_screen.dart';
import '../core/gallery/trip_gallery_screen.dart';
import 'profile/profile_screen.dart';

import '../core/trip/trip_screen.dart';
import '../core/trip/expenses_screen.dart';
import '../core/trip/route_screen.dart';
import '../core/trip/trip_tasks_screen.dart';
import '../core/trip/create_trip_screen.dart';

class MainLayout extends StatefulWidget {
  static const routeName = '/main';
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  /// 🔥 ГЛОБАЛЬНІ ТАБИ
  static const _tabRoutes = [
    '/home',
    '/gallery',
    '/profile',
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
    _navKey.currentState!
        .pushNamedAndRemoveUntil(_tabRoutes[idx], (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navKey.currentState != null &&
            _navKey.currentState!.canPop()) {
          _navKey.currentState!.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Navigator(
          key: _navKey,
          initialRoute: _tabRoutes[_currentIndex],
          onGenerateRoute: (settings) {
            late Widget page;

            switch (settings.name) {
            // ===== TABS =====
              case '/home':
                page = const HomeScreen();
                break;

              case '/gallery':
                page = const AllGalleryScreen(); // 🔥 всі фото
                break;

              case '/profile':
                page = const ProfileScreen();
                break;

            // ===== TRIPS =====
              case TripScreen.routeName:
                page = const TripScreen();
                break;

              case CreateTripScreen.routeName:
                page = const CreateTripScreen();
                break;

              case ExpensesScreen.routeName:
                page = const ExpensesScreen();
                break;

              case RouteScreen.routeName:
                page = const RouteScreen();
                break;

              case TripTasksScreen.routeName:
                page = const TripTasksScreen();
                break;

                break;

            // 🔥 ГАЛЕРЕЯ КОНКРЕТНОЇ ПОДОРОЖІ
              case TripGalleryScreen.routeName:
                page = const TripGalleryScreen();
                break;

              default:
                page = const HomeScreen();
            }

            return MaterialPageRoute(
              builder: (_) => page,
              settings: settings,
            );
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Подорожі',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Галерея',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профіль',
            ),
          ],
        ),
      ),
    );
  }
}
