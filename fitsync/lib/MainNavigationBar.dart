import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'ExercisePage.dart';
import 'TrainplanPage.dart';
import 'MusclePage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    Homepage(),
    ExercisePage(),
    TrainplanPage(),
    Musclepage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:  Color.fromARGB(255, 32, 32, 32),
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        //Navigation bar
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Trains",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.plagiarism),
            label: "Train Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics),
            label: "Muscles",
          ),
        ],
      ),
    );
  }
}