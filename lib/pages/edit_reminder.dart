import 'package:flutter/material.dart';
import '/database_helper.dart';

class EditReminder extends StatefulWidget {
  final int reminderId;
  final String nombre;
  final String cantidad;
  final int frecuencia;  // Cambiado a int
  final String asignado;
  final int diasMedicacion;
  final String horaInicio;
  final String recordar;

  const EditReminder({
    super.key,
    required this.reminderId,
    required this.nombre,
    required this.cantidad,
    required this.frecuencia,  // Cambiado a int
    required this.asignado,
    required this.diasMedicacion,
    required this.horaInicio,
    required this.recordar,
  });

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  final _formKey = GlobalKey<FormState>();

  late String nombre;
  late String cantidad;
  late int frecuencia;  // Cambiado a int
  late String asignado;
  late int diasMedicacion;
  late TimeOfDay horaInicio;
  late String recordar;

  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    nombre = widget.nombre;
    cantidad = widget.cantidad;
    frecuencia = widget.frecuencia;  // Asignado como int
    asignado = widget.asignado;
    diasMedicacion = widget.diasMedicacion;
    horaInicio = TimeOfDay(
        hour: int.parse(widget.horaInicio.split(":")[0]),
        minute: int.parse(widget.horaInicio.split(":")[1]));
    recordar = widget.recordar;
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final members = await DatabaseHelper.instance.getUsers();
    setState(() {
      _familyMembers = members;
    });
  }

  Future<void> _selectHoraInicio(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicio,
    );
    if (picked != null && picked != horaInicio) {
      setState(() {
        horaInicio = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar recordatorio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Editar recordatorio de control de medicamentos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
              const Text("Asignado a:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: asignado,
                items: _familyMembers
                    .map((member) => DropdownMenuItem(
                          value: '${member['id']}-${member['nombre']}',
                          child:
                              Text('${member['nombre']} ${member['apellido']}'),
                        ))
                    .toList(),
                onChanged: (value) => asignado = value!,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) => value == null
                    ? 'Seleccione un miembro de la familia'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text("Frecuencia:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: frecuencia,  // Ahora es un valor int
                items: const [
                  DropdownMenuItem(value: 4, child: Text('4 horas')),
                  DropdownMenuItem(value: 6, child: Text('6 horas')),
                  DropdownMenuItem(value: 8, child: Text('8 horas')),
                  DropdownMenuItem(value: 12, child: Text('12 horas')),
                  DropdownMenuItem(value: 24, child: Text('24 horas')),
                ],
                onChanged: (value) => setState(() {
                  frecuencia = value!;  // Asigna el valor int
                }),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Días para tomar medicación:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (diasMedicacion > 1) {
                          diasMedicacion--;
                        }
                      });
                    },
                  ),
                  Text(
                    '$diasMedicacion día(s)',
                    style: const TextStyle(fontSize: 16),
                  ),
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
              const SizedBox(height: 20),
              const Text("Hora de inicio:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectHoraInicio(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: horaInicio == null
                          ? 'Seleccionar hora de inicio'
                          : 'Hora seleccionada: ${horaInicio.format(context)}',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    controller: TextEditingController(
                        text: horaInicio == null
                            ? ''
                            : horaInicio.format(context)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Recordar:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: recordar,
                items: const [
                  DropdownMenuItem(
                      value: 'Cuando sea la hora',
                      child: Text('Cuando sea la hora')),
                  DropdownMenuItem(
                      value: '5 minutos antes', child: Text('5 minutos antes')),
                ],
                onChanged: (value) => setState(() => recordar = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 50),
              // Botón para guardar los cambios
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final reminder = {
                        'nombre': nombre,
                        'cantidad': cantidad,
                        'frecuencia': frecuencia, // Guardado como int
                        'id_user': asignado.split('-')[0], // Obtener el ID del usuario
                        'dias_medicacion': diasMedicacion, // Guardado como int
                        'hora_inicio': '${horaInicio.hour}:${horaInicio.minute}',
                        'recordar': recordar,
                      };

                      // Actualizar el recordatorio en la base de datos
                      await DatabaseHelper.instance
                          .updateReminderStatus(widget.reminderId, reminder);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Recordatorio actualizado')),
                      );

                      Navigator.pop(context,
                          true); // Indica que se actualizó el recordatorio
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
