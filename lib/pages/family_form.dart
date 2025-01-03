import 'package:flutter/material.dart';
import '/database_helper.dart';

class FamilyForm extends StatefulWidget {
  const FamilyForm({super.key});

  @override
  State<FamilyForm> createState() => _FamilyFormState();
}

class _FamilyFormState extends State<FamilyForm> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellido = '';
  String edad = '';
  String genero = 'Masculino';
  String alergias = '';

  Future<void> _saveToDatabase() async {
    final user = {
      'nombre': nombre,
      'apellido': apellido,
      'edad': int.parse(edad),
      'genero': genero,
      'alergias': alergias,
    };

    try {
      await DatabaseHelper.instance.insertUser(user);
    } catch (e) {
      print('Error al guardar en la base de datos: $e');
      throw Exception('Error al insertar en la base de datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Miembro de la Familia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ingrese los datos de la persona que desea registrar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Campo: Nombre
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  hintText: "Ingresa tu nombre",
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
                decoration: const InputDecoration(
                  labelText: "Apellido",
                  hintText: "Ingresa tu apellido",
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
                decoration: const InputDecoration(
                  labelText: "Edad",
                  hintText: "Ingresa tu edad con número",
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
                decoration: const InputDecoration(
                  labelText: "Alergias",
                  hintText: "Ingresa si tienes alguna/s alergia/s",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    alergias = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              // Botón: Registrar
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _saveToDatabase();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registro guardado con éxito'),
                          ),
                        );
                        Navigator.pop(context, true); // Enviar resultado true al regresar
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al guardar en la base de datos'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Registrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
