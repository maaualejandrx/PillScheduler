import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/create_family.dart';
import 'package:flutter_application_1/pages/create_record.dart';
import 'package:flutter_application_1/pages/home_page.dart';

class WidgetMap extends StatefulWidget {
  const WidgetMap({Key? key}) : super(key: key);

  @override
  State<WidgetMap> createState() => _WidgetMapState();
}


class _WidgetMapState extends State<WidgetMap> {
  int currentIndex = 0;

  List<Widget> body = [
    HomePage(),
    CreateFamily(),
    CreateRecord(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: body[currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.diversity_1), label: "Familia"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Recordatorios"),
        ],
      ),
    );
  }
}
