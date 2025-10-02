import 'Pages/history.dart';
import 'Pages/home.dart';
import 'Pages/New Analysis/new_analysis.dart';
import 'package:flutter/material.dart';
import 'widgets/navbar.dart';
import 'package:beats/components/notifiers.dart';
import 'package:beats/components/styling.dart';
import 'Pages/dummy.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  void initState() {
    super.initState();
    // Seed UI-only dummy data in-memory (no persistence)
    DummyData.seedInMemory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: const Text(
          'ECG Apixaban Advisor',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedIndex, _) {
          return IndexedStack(
            index: selectedIndex,
            children: [
              HomePage(key: const ValueKey('home_page')),
              NewAnalysisPage(key: const ValueKey('new_analysis_page')),
              HistoryPage(key: const ValueKey('history_page')),
            ],
          );
        },
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}