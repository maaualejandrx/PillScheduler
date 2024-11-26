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
      resizeToAvoidBottomInset:
          true, // Permite el ajuste de la pantalla cuando aparece el teclado
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
              const SizedBox(
                  height:
                      50), // Espacio extra para asegurar que el botón no se solape
              // El ElevatedButton en lugar del FloatingActionButton
              Center(
                child: Tooltip(
                  message:
                      'Guardar Recordatorio', // El texto que aparecerá cuando se mantenga presionado el botón
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
