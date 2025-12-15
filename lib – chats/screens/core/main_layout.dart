import 'package:flutter/material.dart';

import '../core/home_screen.dart';
import '../core/chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';
import '../core/trip/trip_screen.dart';
import '../core/trip/expenses_screen.dart';
import 'trip/route_screen.dart';
import '../core/trip/trip_tasks_screen.dart';
import '../core/trip/trip_participants_screen.dart';
import '../core/trip/create_trip_screen.dart';
import '../core/chat/chat_screen.dart';
class MainLayout extends StatefulWidget {
  static const routeName = '/main';
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  static const _tabRoutes = ['/home', '/chats', '/profile'];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
    _navKey.currentState!.pushNamedAndRemoveUntil(_tabRoutes[idx], (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navKey.currentState != null && _navKey.currentState!.canPop()) {
          _navKey.currentState!.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(

        body: Navigator(

          key: _navKey,
          initialRoute: _tabRoutes[_currentIndex],
          onGenerateRoute: (RouteSettings settings) {
            Widget page;
            final args = settings.arguments;
            switch (settings.name) {
              case '/home':
                page = const HomeScreen();
                break;
              case '/chats':
                page = const ChatListScreen();
                break;
              case '/profile':
                page = const ProfileScreen();
                break;

              case TripScreen.routeName:
                page = const TripScreen();
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
              case TripParticipantsScreen.routeName:
                page = const TripParticipantsScreen();
                break;
              case CreateTripScreen.routeName:
                page = const CreateTripScreen();
                break;
              case ChatScreen.routeName:
                  page = const ChatScreen();
              default:
              // fallback
                page = const HomeScreen();
            }
            return MaterialPageRoute(builder: (_) => page, settings: settings);
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Подорожі'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Чати'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
          ],
        ),
      ),
    );
  }
}
