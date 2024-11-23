import 'package:flutter/material.dart';
import 'family_form.dart'; // Importa el archivo donde está FamilyForm

class CreateFamily extends StatefulWidget {
  const CreateFamily({super.key});

  @override
  State<CreateFamily> createState() => _CreateFamilyState();
}

class _CreateFamilyState extends State<CreateFamily> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controla a tu familia!'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('Aquí va la listview de la familia'),
          ),
          const SizedBox(height: 20), // Espacio entre el texto y el botón
          ElevatedButton(
            onPressed: () {
              // Navegar a FamilyForm
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FamilyForm(),
                ),
              );
            },
            child: const Text('Agregar Familia'),
          ),
        ],
      ),
    );
  }
}
