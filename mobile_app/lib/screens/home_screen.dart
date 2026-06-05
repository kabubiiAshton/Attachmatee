import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_state.dart';
import 'admin/admin_dashboard.dart';
import 'company/company_dashboard.dart';
import 'student/student_dashboard.dart';
import 'applications_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'opportunities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Widget> _buildScreens(String role) {
    if (role == 'admin') {
      return const [
        AdminDashboard(),
        ApplicationsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];
    }
    if (role == 'company') {
      return const [
        CompanyDashboard(),
        ApplicationsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];
    }
    return const [
      StudentDashboard(),
      OpportunitiesScreen(),
      ApplicationsScreen(),
      NotificationsScreen(),
      ProfileScreen(),
    ];
  }

  List<String> _buildTitles(String role) {
    if (role == 'admin') {
      return const ["Dashboard", "Applications", "Notifications", "Profile"];
    }
    if (role == 'company') {
      return const ["Dashboard", "Applications", "Notifications", "Profile"];
    }
    return const ["Dashboard", "Opportunities", "Applications", "Notifications", "Profile"];
  }

  List<NavigationDestination> _buildDestinations(String role) {
    if (role == 'admin' || role == 'company') {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: "Applications",
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: "Alerts",
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    }
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: "Home",
      ),
      NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: "Jobs",
      ),
      NavigationDestination(
        icon: Icon(Icons.description_outlined),
        selectedIcon: Icon(Icons.description),
        label: "Applications",
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: "Alerts",
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: "Profile",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthState>().role ?? 'student';
    final screens = _buildScreens(role);
    final titles = _buildTitles(role);
    final destinations = _buildDestinations(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),

        automaticallyImplyLeading: false,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              titles[currentIndex],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),

        actions: [

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Color(0xFF0F172A),
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                currentIndex = titles.indexOf('Notifications');
              });
            },
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 28,
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[currentIndex],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          12,
        ),
        child: NavigationBar(
          height: 75,
          selectedIndex: currentIndex,
          elevation: 10,
          backgroundColor: Colors.white,
          indicatorColor:
              const Color(0xFFDBEAFE),
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: destinations,
        ),
      ),
    );
  }
}
