import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '/database_helper.dart';
import '/notification_service.dart';

class CreateRecord extends StatefulWidget {
  const CreateRecord({super.key});

  @override
  State<CreateRecord> createState() => _CreateRecordState();
}

class _CreateRecordState extends State<CreateRecord> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String cantidad = '';
  String? asignado;
  int frecuencia = 4; // Frecuencia en horas
  List<Map<String, dynamic>> _familyMembers = [];
  int diasMedicacion = 1; // Días para tomar la medicación
  TimeOfDay? horaInicio; // Hora de inicio
  int recordar = 0; // 0: a la hora exacta, 1: 5 minutos antes

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final members = await DatabaseHelper.instance.getUsers();
    setState(() {
      _familyMembers = members;
      if (_familyMembers.isNotEmpty) {
        asignado = '${_familyMembers[0]['id']}-${_familyMembers[0]['nombre']}';
      }
    });
  }

  Future<void> _selectHoraInicio(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicio ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        horaInicio = picked;
      });
    }
  }

  /// Genera un ID único para las notificaciones
  int _generateNotificationId(DateTime time, int recordatorioId) {
    return (recordatorioId + time.millisecondsSinceEpoch) % 1000000;
  }

  /// Programa las notificaciones
  Future<void> _scheduleNotifications(
    int recordatorioId,
    String usuario,
    String medicamento,
    String cantidad,
    TimeOfDay horaInicio,
    int frecuencia,
    int diasMedicacion,
    int recordar,
  ) async {
    final now = DateTime.now();

    DateTime nextNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      horaInicio.hour,
      horaInicio.minute,
    );

    if (nextNotificationTime.isBefore(now)) {
      nextNotificationTime = nextNotificationTime.add(Duration(hours: frecuencia));
    }

    await NotificationService.showNotification(
      id: _generateNotificationId(now, recordatorioId),
      title: "¡No olvides tomar tu medicación!",
      body: "$usuario, no olvides tomar tu medicación en las próximas $frecuencia horas.",
    );

    final DateTime endDate = nextNotificationTime.add(Duration(days: diasMedicacion));

    while (nextNotificationTime.isBefore(endDate)) {
      final adjustedTime = recordar == 1
          ? nextNotificationTime.subtract(const Duration(minutes: 5))
          : nextNotificationTime;

      await NotificationService.scheduleNotification(
        id: _generateNotificationId(nextNotificationTime, recordatorioId),
        title: "Es hora de tu medicación",
        body: "$usuario debe tomar ($cantidad) de $medicamento.",
        scheduledTime: tz.TZDateTime.from(adjustedTime, tz.local),
      );

      nextNotificationTime = nextNotificationTime.add(Duration(hours: frecuencia));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear recordatorio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Crear recordatorio de control de medicamentos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nombre del medicamento",
                  hintText: "Ej. Paracetamol",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => nombre = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Cantidad",
                  hintText: "Ej. 500mg",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => cantidad = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese la cantidad' : null,
              ),
              const SizedBox(height: 20),
              const Text("Asignado a:", style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: asignado,
                items: _familyMembers
                    .map((member) => DropdownMenuItem(
                          value: '${member['id']}-${member['nombre']}',
                          child:
                              Text('${member['nombre']} ${member['apellido']}'),
                        ))
                    .toList(),
                onChanged: (value) => asignado = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) =>
                    value == null ? 'Seleccione un miembro de la familia' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: frecuencia,
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('4 horas')),
                        DropdownMenuItem(value: 6, child: Text('6 horas')),
                        DropdownMenuItem(value: 8, child: Text('8 horas')),
                        DropdownMenuItem(value: 12, child: Text('12 horas')),
                        DropdownMenuItem(value: 24, child: Text('24 horas')),
                      ],
                      onChanged: (value) => setState(() => frecuencia = value!),
                      decoration: const InputDecoration(
                        labelText: "Frecuencia",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (diasMedicacion > 1) diasMedicacion--;
                          });
                        },
                      ),
                      Text('$diasMedicacion día(s)',
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            diasMedicacion++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectHoraInicio(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: horaInicio == null
                          ? 'Seleccionar hora de inicio'
                          : 'Hora seleccionada: ${horaInicio!.format(context)}',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    controller: TextEditingController(
                        text: horaInicio == null
                            ? ''
                            : horaInicio!.format(context)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Recordar:", style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<int>(
                value: recordar,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Cuando sea la hora')),
                  DropdownMenuItem(value: 1, child: Text('5 minutos antes')),
                ],
                onChanged: (value) => setState(() => recordar = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final reminder = {
                        'nombre': nombre,
                        'cantidad': cantidad,
                        'frecuencia': frecuencia,
                        'id_user': asignado!.split('-')[0],
                        'dias_medicacion': diasMedicacion,
                        'hora_inicio': horaInicio != null
                            ? '${horaInicio!.hour}:${horaInicio!.minute}'
                            : null,
                        'recordar': recordar,
                      };

                      final recordatorioId = await DatabaseHelper.instance
                          .insertReminder(reminder);

                      final usuario = asignado!.split('-')[1];

                      if (horaInicio != null) {
                        await _scheduleNotifications(
                          recordatorioId,
                          usuario,
                          nombre,
                          cantidad,
                          horaInicio!,
                          frecuencia,
                          diasMedicacion,
                          recordar,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recordatorio creado con éxito'),
                        ),
                      );
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Recordatorio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
