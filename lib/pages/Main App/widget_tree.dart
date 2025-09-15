import 'History/history.dart';
import 'Home/home.dart';
import 'New Analysis/new_analysis.dart';
import 'package:flutter/material.dart';
import 'widgets/navbar.dart';
import 'package:beats/components/notifiers.dart';
import 'package:beats/components/styling.dart';

const List<Widget> pages = [
  HomePage(),
  NewAnalysisPage(),
  HistoryPage(),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'ECG Apixaban Advisor',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedIndex, _) => pages[selectedIndex],
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}