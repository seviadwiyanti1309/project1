import 'package:flutter/material.dart';
import 'document_page.dart';
import 'interview_page.dart';
import 'job_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainLayout(), // ← gunakan layout utama
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // daftar halaman yang ingin ditampilkan
  final List<Widget> _pages = const [
    HomePage(),
    JobPage(),     // nanti bisa ganti page lain
    Center(child: Text("Search")),
    InterviewPage(),
    DocumentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // tampilan berubah sesuai navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B06A9),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline, size: 28),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined, size: 28),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined, size: 28),
            label: 'Documents',
          ),
        ],
      ),
    );
  }
}
