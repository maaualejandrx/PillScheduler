import 'package:flutter/material.dart';
import 'family_form.dart'; // Importa el archivo donde está FamilyForm
import '/database_helper.dart'; // Importa la clase para manejar la base de datos
import 'edit_family.dart'; // Importa el archivo para editar familiares

class CreateFamily extends StatefulWidget {
  const CreateFamily({super.key});

  @override
  State<CreateFamily> createState() => _CreateFamilyState();
}

class _CreateFamilyState extends State<CreateFamily> {
  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchFamilyMembers(); // Cargar los registros de la base de datos al iniciar
  }

  // Función para obtener los datos de la base de datos
  Future<void> _fetchFamilyMembers() async {
    final members = await DatabaseHelper.instance.getUsers();
    setState(() {
      _familyMembers = members;
    });
  }

  // Función para eliminar un miembro de la familia
  Future<void> _deleteFamilyMember(int id) async {
    try {
      await DatabaseHelper.instance.deleteUser(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Familiar eliminado con éxito')),
      );
      _fetchFamilyMembers(); // Actualizar la lista después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el familiar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado Familia'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Listado de Familiares',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _familyMembers.isEmpty
                ? const Center(
                    child: Text('No hay familiares registrados.'),
                  )
                : ListView.builder(
                    itemCount: _familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = _familyMembers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            'Nombre: ${member['nombre']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Apellido: ${member['apellido']}'),
                              Text('Edad: ${member['edad']} años'),
                              Text('Alergia: ${member['alergias']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // Navegar al formulario de edición y esperar hasta que regrese
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditFamily(user: member),
                                    ),
                                  );

                                  // Si se actualizó el registro, recargar la lista
                                  if (result == true) {
                                    _fetchFamilyMembers();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Confirmar antes de eliminar
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: const Text(
                                            '¿Estás seguro de que deseas eliminar este familiar?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    _deleteFamilyMember(member['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar al formulario y esperar hasta que regrese
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FamilyForm(),
            ),
          );

          // Si se agregó un registro, actualiza la lista
          if (result == true) {
            _fetchFamilyMembers();
          }
        },
        tooltip: 'Agregar Familiar',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
