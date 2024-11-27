import 'package:flutter/material.dart';
import '/database_helper.dart';

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
  int frecuencia = 4; // Ahora es un entero
  List<Map<String, dynamic>> _familyMembers = [];
  int diasMedicacion = 1; // Campo para ingresar los días para tomar medicación
  TimeOfDay? horaInicio; // Campo para hora de inicio
  int recordar = 0; // 0 para "Cuando sea la hora", 1 para "5 minutos antes"

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

  // Función para seleccionar la hora de inicio
  Future<void> _selectHoraInicio(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicio ?? TimeOfDay.now(),
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
      resizeToAvoidBottomInset: true,
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
                onChanged: (value) => asignado = value,
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
              Row(
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
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Espacio entre los dos campos
                  // Botón para ingresar días para tomar medicación
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Días para tomar medicación:",
                          style: TextStyle(fontSize: 16)),
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
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Hora de inicio
              const Text("Hora de inicio:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
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
              // Opción de recordar
              const Text("Recordar:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
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
              // El ElevatedButton en lugar del FloatingActionButton
              Center(
                child: Tooltip(
                  message: 'Guardar Recordatorio',
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final reminder = {
                          'nombre': nombre,
                          'cantidad': cantidad,
                          'frecuencia': frecuencia, // Guardado como entero
                          'id_user': asignado!.split('-')[0],
                          'dias_medicacion':
                              diasMedicacion, // Guardado como entero
                          'hora_inicio': horaInicio != null
                              ? '${horaInicio!.hour}:${horaInicio!.minute}'
                              : null,
                          'recordar': recordar, // Guardado como entero
                        };
                        await DatabaseHelper.instance.insertReminder(reminder);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Recordatorio creado con éxito')),
                        );
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.save), // Ícono de guardar
                    label: const Text(''), // El label está vacío, solo el ícono
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
