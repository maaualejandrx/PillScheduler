import 'package:flutter/material.dart';
import '/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DatabaseHelper.instance.getDetailedReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id);
    _loadReminders();
  }

  Future<void> _toggleReminderStatus(int id, bool isActive) async {
    await DatabaseHelper.instance.updateReminderStatus(id, isActive ? 1 : 0);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Recordatorios'),
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Text("No hay recordatorios creados."),
            )
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(reminder['nombre']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${reminder['cantidad']}'),
                        Text('Frecuencia: ${reminder['frecuencia']}'),
                        Text('Asignado a: ${reminder['asignado']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: reminder['activo'] == 1,
                          onChanged: (value) {
                            _toggleReminderStatus(reminder['id'], value);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(reminder['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}