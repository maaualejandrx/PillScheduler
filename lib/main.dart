import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'pages/create_family.dart';
import 'pages/create_record.dart';
import 'pages/home_page.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Instancia global de FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(); // Inicializa las notificaciones
  tz.initializeTimeZones();

  // Verifica los permisos para alarmas exactas
  await checkExactAlarmPermission();

  runApp(const MainApp());
}

/// Inicializa las notificaciones
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  await _notificationsPlugin.initialize(initializationSettings);
}

/// Verifica si las alarmas exactas están permitidas y solicita permiso si es necesario
Future<void> checkExactAlarmPermission() async {
  final androidPlugin =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    // Intenta verificar el permiso para alarmas exactas
    final isExactAlarmAllowed =
        await androidPlugin.areNotificationsEnabled() ?? false;

    if (!isExactAlarmAllowed) {
      // Muestra un mensaje al usuario
      print(
        "Por favor, habilita las alarmas exactas manualmente en Configuración > Aplicaciones > [Tu aplicación] > Permisos > Alarmas exactas.",
      );
    }

// Informa al usuario si las alarmas exactas no están habilitadas
    print(
      "Si usas alarmas exactas, verifica manualmente en Configuración > Aplicaciones > [Tu aplicación] > Permisos > Alarmas exactas.",
    );
  }
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

  void showExactAlarmPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permiso de Alarmas Exactas"),
          content: const Text(
              "Por favor, habilita las alarmas exactas manualmente en Configuración > Aplicaciones > [Tu aplicación] > Permisos > Alarmas exactas."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}
