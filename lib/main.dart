import 'package:flutter/material.dart';
import 'pages/create_family.dart';
import 'pages/create_record.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WidgetMap(),
      routes: {
        '/createRecord': (context) => const CreateRecord(),
        '/createFamily': (context) => const CreateFamily(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class WidgetMap extends StatefulWidget {
  const WidgetMap({super.key});

  @override
  State<WidgetMap> createState() => _WidgetMapState();
}

class _WidgetMapState extends State<WidgetMap> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    CreateFamily(),
    CreateRecord(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      debugPrint('Página actual: $_selectedIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Familia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Recordatorios',
          ),
        ],
      ),
    );
  }
}
