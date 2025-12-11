import 'package:flutter/material.dart';
import '../services/exercicio_service.dart';

class Musclepage extends StatefulWidget {
  const Musclepage({super.key});

  @override
  State<Musclepage> createState() => _MusclePageState();
}

class _MusclePageState extends State<Musclepage> {
  final ExercicioService _exercicioService = ExercicioService();
  List<Map<String, dynamic>> muscles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMuscle();
  }

  //load to muscle
  Future<void> loadMuscle() async {
    try {
      final lista = await _exercicioService.getMuscle();

      if (!mounted) return;

      setState(() {
        muscles = lista;
        loading = false;
      });
    } catch (e) {
      print("Erro to load: $e");
    }
  }

  // add muscle
  Future<void> adicionarMusculo() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return _styledDialog(
          title: "Add Muscle",
          confirmText: "Save",
          controller: controller,
          onConfirm: () async {
            final nome = controller.text.trim();
            if (nome.isEmpty) return;

            await _exercicioService.postMuscle({"MuscleName": nome});
            Navigator.pop(context);
            loadMuscle();
          },
        );
      },
    );
  }

  //edit muscle
  Future<void> editMuscle(String id, String nomeAtual) async {
    final controller = TextEditingController(text: nomeAtual);

    await showDialog(
      context: context,
      builder: (context) {
        return _styledDialog(
          title: "Edit Muscle",
          confirmText: "Update",
          controller: controller,
          onConfirm: () async {
            final novoNome = controller.text.trim();
            if (novoNome.isEmpty) return;

            await _exercicioService.updateMuscle(id, {"MuscleName": novoNome});
            Navigator.pop(context);
            loadMuscle();
          },
        );
      },
    );
  }

  //delete muscle
  Future<void> deleteMuscle(String id) async {
    await _exercicioService.deleteMuscle(id);
    loadMuscle();
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: adicionarMusculo,
      ),

      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        elevation: 4,
        title: const Text(
          "Muscles",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
            : muscles.isEmpty
                ? _noMuscle()
                : _muscleList(),
      ),
    );
  }

  //muscle List
  Widget _muscleList() {
    return ListView.builder(
      itemCount: muscles.length,
      itemBuilder: (context, index) {
        final muscle = muscles[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + index * 60),
          curve: Curves.easeOut,
          child: _muscleCard(muscle),
        );
      },
    );
  }

  // empyt state
  Widget _noMuscle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 15),
          Text(
            "No muscle",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // muscle card
  Widget _muscleCard(Map<String, dynamic> muscle) {
    final id = muscle["id"];
    final nome = muscle["MuscleName"] ?? "No name";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 54, 54, 54), Colors.greenAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: Text(
          nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          "Created at System",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => editMuscle(id, nome),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => deleteMuscle(id),
            ),
          ],
        ),
      ),
    );
  }

//  Dialog
  Widget _styledDialog({
    required String title,
    required String confirmText,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Muscle Name",
          labelStyle: const TextStyle(color: Colors.white70),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.greenAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
