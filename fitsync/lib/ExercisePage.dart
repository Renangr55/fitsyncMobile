import 'package:flutter/material.dart';
import 'services/exercicio_service.dart';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ExercicioService _service = ExercicioService();

  // Inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController repetitionController = TextEditingController();
  final TextEditingController seriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      appBar: AppBar(
        title: const Text(
          "Exercises",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor:  Colors.black,
        elevation: 4,
      ),
      
      body: FutureBuilder(
        future: _service.getExecise(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color:  Colors.greenAccent));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum exercício encontrado",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }

          final exercises = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return _exerciseCard(ex);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:  Colors.greenAccent,
        elevation: 5,
        icon: const Icon(Icons.add, size: 28),
        label: const Text("Add", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () => _openExerciseModal(context),
      ),
    );
  }

  // ------------------------------------
  // CARD COM EDITAR E DELETAR
  // ------------------------------------
  Widget _exerciseCard(Map<String, dynamic> ex) {
    final id = ex["id"];
    final muscleName = ex["TypeMuscle"]?["MuscleName"] ?? "Sem músculo";

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) async {
        await _service.deleteExercise(id);
        setState(() {});
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ex["ExerciseName"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:  Colors.greenAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.greenAccent),
                  onPressed: () => _openExerciseModal(context, exercise: ex),
                )
              ],
            ),

            const SizedBox(height: 8),
            Text("Repetition: ${ex["Repetition"]}", style: const TextStyle(color: Colors.white)),
            Text("Series: ${ex["Series"]}", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.fitness_center, color:  Colors.greenAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  muscleName,
                  style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------
  // MODAL DE CRIAR / EDITAR
  // ------------------------------------
  void _openExerciseModal(BuildContext context, {Map<String, dynamic>? exercise}) async {
    final muscles = await _service.getMuscle();
    String? selectedMuscleId;

    // Preenche os campos se for edição
    if (exercise != null) {
      nameController.text = exercise["ExerciseName"];
      repetitionController.text = exercise["Repetition"];
      seriesController.text = exercise["Series"];
      selectedMuscleId = exercise["TypeMuscle"]?["id"];
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                exercise == null ? "New Exercise" : "Edit Exercise",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _styledInput(controller: nameController, label: "Name", icon: Icons.fitness_center),
                      const SizedBox(height: 12),

                      _styledInput(controller: repetitionController, label: "Repetition", icon: Icons.repeat),
                      const SizedBox(height: 12),

                      _styledInput(controller: seriesController, label: "Series", icon: Icons.numbers),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[850],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Selecione o músculo",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedMuscleId,
                        items: muscles.map<DropdownMenuItem<String>>((muscle) {
                          return DropdownMenuItem<String>(
                            value: muscle["id"],
                            child: Text(muscle["MuscleName"], style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedMuscleId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    nameController.clear();
                    repetitionController.clear();
                    seriesController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (selectedMuscleId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Select a muscle")),
                      );
                      return;
                    }

                    if (exercise == null) {
                      await _service.createExercise(
                        exerciseName: nameController.text,
                        repetition: repetitionController.text,
                        series: seriesController.text,
                        muscleId: selectedMuscleId!,
                      );
                    } else {
                      await _service.updateExercise(
                        exercise["id"],
                        {
                          "ExerciseName": nameController.text,
                          "Repetition": repetitionController.text,
                          "Series": seriesController.text,
                          "TypeMuscleId": selectedMuscleId!,
                        },
                      );
                    }

                    nameController.clear();
                    repetitionController.clear();
                    seriesController.clear();

                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text(exercise == null ? "Salvar" : "Atualizar"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Campo estilizado
  Widget _styledInput({required TextEditingController controller, required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color:  Colors.greenAccent),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color:  Colors.greenAccent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.greenAccent, width: 2)),
      ),
    );
  }
}
