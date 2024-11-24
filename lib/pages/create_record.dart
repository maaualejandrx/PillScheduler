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
  String frecuencia = '4 horas';
  List<Map<String, dynamic>> _familyMembers = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear recordatorio'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      hintText: "Cantidad (ej. 1 pastilla)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => cantidad = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la cantidad' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("Asignado a:", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: asignado,
                    items: _familyMembers
                        .map((member) => DropdownMenuItem(
                              value: '${member['id']}-${member['nombre']}',
                              child: Text('${member['nombre']} ${member['apellido']}'),
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
                  DropdownButtonFormField<String>(
                    value: frecuencia,
                    items: const [
                      DropdownMenuItem(value: '4 horas', child: Text('4 horas')),
                      DropdownMenuItem(value: '6 horas', child: Text('6 horas')),
                      DropdownMenuItem(value: '8 horas', child: Text('8 horas')),
                      DropdownMenuItem(value: '12 horas', child: Text('12 horas')),
                      DropdownMenuItem(value: '24 horas', child: Text('24 horas')),
                    ],
                    onChanged: (value) => frecuencia = value!,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final reminder = {
                      'nombre': nombre,
                      'cantidad': cantidad,
                      'frecuencia': frecuencia,
                      'id_user': asignado!.split('-')[0],
                    };
                    await DatabaseHelper.instance.insertReminder(reminder);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recordatorio creado con éxito')),
                    );
                 Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
