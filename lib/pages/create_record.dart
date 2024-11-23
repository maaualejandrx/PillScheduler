import 'package:flutter/material.dart';

class CreateRecord extends StatefulWidget {
  const CreateRecord({super.key});

  @override
  State<CreateRecord> createState() => _CreateRecordState();
}

class _CreateRecordState extends State<CreateRecord> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String cantidad = '';
  String asignado = 'Luz'; // Valor inicial del DropdownButton
  String frecuencia = '4 horas'; // Valor inicial para frecuencia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear recordatorio'),
      ),
      resizeToAvoidBottomInset: false, // Evita que el diseño se ajuste con el teclado
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
                  // Campo: Nombre
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      hintText: "Nombre del medicamento",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        nombre = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre del medicamento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Campo: Cantidad
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Cantidad",
                      hintText: "Cantidad (ej. 1 pastilla)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        cantidad = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cantidad';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // DropdownButton: Asignado a
                  const Text(
                    "Asignado a:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: asignado,
                    items: const [
                      DropdownMenuItem(
                        value: 'Luz',
                        child: Text('Luz'),
                      ),
                      DropdownMenuItem(
                        value: 'Mau',
                        child: Text('Mau'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        asignado = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // DropdownButton: Frecuencia
                  const Text(
                    "Frecuencia:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: frecuencia,
                    items: const [
                      DropdownMenuItem(
                        value: '4 horas',
                        child: Text('4 horas'),
                      ),
                      DropdownMenuItem(
                        value: '6 horas',
                        child: Text('6 horas'),
                      ),
                      DropdownMenuItem(
                        value: '8 horas',
                        child: Text('8 horas'),
                      ),
                      DropdownMenuItem(
                        value: '12 horas',
                        child: Text('12 horas'),
                      ),
                      DropdownMenuItem(
                        value: '24 horas',
                        child: Text('24 horas'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        frecuencia = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón flotante fijo
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recordatorio creado con éxito'),
                      ),
                    );
                  }
                },
                label: const Text('Guardar'),
                icon: const Icon(Icons.alarm),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
