import 'package:flutter/material.dart';
import '/database_helper.dart';

class EditReminder extends StatefulWidget {
  final int reminderId;
  final String nombre;
  final String cantidad;
  final int frecuencia;
  final String asignado;
  final int diasMedicacion;
  final String? horaInicio;
  final int recordar;

  const EditReminder({
    super.key,
    required this.reminderId,
    required this.nombre,
    required this.cantidad,
    required this.frecuencia,
    required this.asignado,
    required this.diasMedicacion,
    this.horaInicio,
    required this.recordar,
  });

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  final _formKey = GlobalKey<FormState>();

  late String nombre;
  late String cantidad;
  late String? asignado;
  late int frecuencia;
  late int diasMedicacion;
  TimeOfDay? horaInicio;
  late int recordar;
  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    nombre = widget.nombre;
    cantidad = widget.cantidad;
    frecuencia = widget.frecuencia;
    asignado = widget.asignado;
    diasMedicacion = widget.diasMedicacion;
    recordar = widget.recordar;
    if (widget.horaInicio != null) {
      final timeParts = widget.horaInicio!.split(':');
      horaInicio = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final members = await DatabaseHelper.instance.getUsers();
    setState(() {
      _familyMembers = members;
      // Validar que asignado sea parte de la lista actual
      if (!_familyMembers.any(
          (member) => '${member['id']}-${member['nombre']}' == asignado)) {
        asignado = null; // Si no coincide, se establece como null
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

  Future<void> _updateReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = {
        'nombre': nombre,
        'cantidad': cantidad,
        'frecuencia': frecuencia,
        'id_user': asignado?.split('-')[0],
        'dias_medicacion': diasMedicacion,
        'hora_inicio': horaInicio != null
            ? '${horaInicio!.hour}:${horaInicio!.minute}'
            : null,
        'recordar': recordar,
      };

      await DatabaseHelper.instance.updateReminderStatus(widget.reminderId, reminder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio actualizado con éxito')),
      );
      Navigator.of(context).pop(true); // Devuelve true para indicar éxito
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Recordatorio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: nombre,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  hintText: "Nombre del medicamento",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => nombre = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: cantidad,
                decoration: const InputDecoration(
                  labelText: "Cantidad",
                  hintText: "Cantidad (ej. 500mg)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => cantidad = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese la cantidad'
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: asignado,
                items: _familyMembers
                    .map((member) => DropdownMenuItem(
                          value: '${member['id']}-${member['nombre']}',
                          child: Text(
                              '${member['nombre']} ${member['apellido']}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  asignado = value;
                }),
                decoration: const InputDecoration(
                  labelText: "Asignado a",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null
                    ? 'Seleccione un miembro de la familia'
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: recordar,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Cuando sea la hora')),
                  DropdownMenuItem(value: 1, child: Text('5 minutos antes')),
                ],
                onChanged: (value) => setState(() => recordar = value!),
                decoration: const InputDecoration(
                  labelText: "Recordar",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _updateReminder,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
