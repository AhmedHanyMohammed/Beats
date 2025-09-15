import 'package:flutter/material.dart';
import 'package:beats/data/notifiers.dart';
import 'package:beats/data/styling.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, int selectedPage, _) {
        return NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (states) => states.contains(WidgetState.selected)
                  ? const IconThemeData(color: primaryColor)
                  : const IconThemeData(color: neutralIconColor),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
                final common = baseTextStyle.copyWith(fontWeight: FontWeight.w700);
                return states.contains(WidgetState.selected)
                    ? common.copyWith(color: primaryColor)
                    : common.copyWith(color: neutralIconColor);
              },
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Material(
              color: Colors.white,
              child: NavigationBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                selectedIndex: selectedPage,
                onDestinationSelected: (int value) {
                  selectedPageNotifier.value = value;
                },
                indicatorColor: primaryColor.withAlpha(41),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    selectedIcon: Icon(Icons.add_circle_rounded),
                    label: 'New Analysis',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history),
                    selectedIcon: Icon(Icons.history),
                    label: 'History',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
