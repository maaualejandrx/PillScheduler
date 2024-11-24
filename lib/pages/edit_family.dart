import 'package:flutter/material.dart';
import '/database_helper.dart';

class EditFamily extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditFamily({super.key, required this.user});

  @override
  State<EditFamily> createState() => _EditFamilyState();
}

class _EditFamilyState extends State<EditFamily> {
  final _formKey = GlobalKey<FormState>();
  late String nombre;
  late String apellido;
  late String edad;
  late String genero;
  late String alergias;

  @override
  void initState() {
    super.initState();
    // Inicializar los campos con los datos del usuario
    nombre = widget.user['nombre'];
    apellido = widget.user['apellido'];
    edad = widget.user['edad'].toString();
    genero = widget.user['genero'];
    alergias = widget.user['alergias'] ?? '';
  }

  Future<void> _updateUser() async {
    final updatedUser = {
      'id': widget.user['id'],
      'nombre': nombre,
      'apellido': apellido,
      'edad': int.parse(edad),
      'genero': genero,
      'alergias': alergias,
    };

    try {
      await DatabaseHelper.instance.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados con éxito'),
        ),
      );
      Navigator.pop(context, true); // Regresar con un resultado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar los datos'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Miembro de la Familia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Actualiza los datos de la persona:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Campo: Nombre
              TextFormField(
                initialValue: nombre,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    nombre = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo: Apellido
              TextFormField(
                initialValue: apellido,
                decoration: const InputDecoration(
                  labelText: "Apellido",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    apellido = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo: Edad
              TextFormField(
                initialValue: edad,
                decoration: const InputDecoration(
                  labelText: "Edad",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    edad = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la edad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Selección de Género
              const Text(
                "Género:",
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Masculino"),
                      value: "Masculino",
                      groupValue: genero,
                      onChanged: (value) {
                        setState(() {
                          genero = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Femenino"),
                      value: "Femenino",
                      groupValue: genero,
                      onChanged: (value) {
                        setState(() {
                          genero = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campo: Alergias
              TextFormField(
                initialValue: alergias,
                decoration: const InputDecoration(
                  labelText: "Alergias",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    alergias = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              // Botón: Guardar Cambios
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _updateUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Guardar Cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
