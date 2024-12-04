import 'package:flutter/material.dart';
import '/database_helper.dart';
import 'edit_reminder.dart';

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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar este recordatorio?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await DatabaseHelper.instance.deleteReminder(id);
      _loadReminders();
    }
  }

  Future<void> _toggleReminderStatus(int id, bool isActive) async {
    await DatabaseHelper.instance.updateReminderStatus(
      id,
      {'activo': isActive ? 1 : 0},
    );
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
                        Text(
                            'Frecuencia: ${int.tryParse(reminder['frecuencia'].toString()) ?? 0} horas'),
                        Text('Asignado a: ${reminder['asignado'] ?? 'No asignado'}'),
                        Text('Hora de inicio: ${reminder['hora_inicio'] ?? 'No especificada'}'),
                        Text(
                            'Días para tomar: ${reminder['dias_medicacion'] ?? 1}'),
                      ],
                    ),
                    onLongPress: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReminder(
                            reminderId: reminder['id'],
                            nombre: reminder['nombre'],
                            cantidad: reminder['cantidad'],
                            frecuencia: int.tryParse(
                                    reminder['frecuencia'].toString()) ??
                                0,
                            asignado: reminder['id_user'].toString(),
                            diasMedicacion:
                                int.tryParse(reminder['dias_medicacion'].toString()) ??
                                    1,
                            horaInicio: reminder['hora_inicio'],
                            recordar: int.tryParse(reminder['recordar'].toString()) ?? 0,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadReminders(); // Recarga la lista después de editar
                      }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: reminder['activo'] == 1 ? true : false,
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
