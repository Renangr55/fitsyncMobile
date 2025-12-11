import 'package:flutter/material.dart';
import '../services/exercicio_service.dart';

class TrainplanPage extends StatefulWidget {
  const TrainplanPage({super.key});

  @override
  State<TrainplanPage> createState() => _TrainplanPageState();
}

class _TrainplanPageState extends State<TrainplanPage> {
  final ExercicioService _service = ExercicioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Training Plans",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
        elevation: 4,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openTrainingPlanModal(context),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.getTrainingPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "I can't find the correct train schedule",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final plans = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _planCard(plan);
            },
          );
        },
      ),
    );
  }

  //cardPlan
  Widget _planCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan["Name"],
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Botões de editar e deletar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.greenAccent),
                    onPressed: () => _openTrainingPlanModal(
                      context,
                      planToEdit: plan,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await _service.deleteTrainingPlan(plan["id"]);
                      setState(() {});
                    },
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 6),
          Text(
            plan["Description"],
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),

          Text(
            "Exercises: ${plan["Exercises"].join(", ")}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Muscles: ${plan["Muscles"].join(", ")}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  //create and update Train plan
  void _openTrainingPlanModal(BuildContext context, {Map<String, dynamic>? planToEdit}) async {
    final exercises = await _service.getExecise();
    final muscles = await _service.getMuscle();

    final TextEditingController nameController = TextEditingController(text: planToEdit?["Name"] ?? "");
    final TextEditingController descController = TextEditingController(text: planToEdit?["Description"] ?? "");

    // muscles and Exercises
    List<String> selectedExercises = [];
    List<String> selectedMuscles = [];

    if (planToEdit != null) {
      selectedExercises = List<String>.from(planToEdit["ExercisesIds"] ?? []);
      selectedMuscles = List<String>.from(planToEdit["MusclesIds"] ?? []);
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
                planToEdit == null ? "New Training Plan" : "Edit Training Plan",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _styledInput(controller: nameController, label: "Name"),
                      const SizedBox(height: 12),
                      _styledInput(controller: descController, label: "Description"),
                      const SizedBox(height: 12),

                      // select exercises
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[850],
                        decoration: InputDecoration(
                          labelText: "Select Exercise",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: null,
                        items: exercises.map((ex) {
                          return DropdownMenuItem<String>(
                            value: ex["id"],
                            child: Text(ex["ExerciseName"], style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && !selectedExercises.contains(value)) {
                            setModalState(() => selectedExercises.add(value));
                          }
                        },
                      ),
                      Wrap(
                        spacing: 6,
                        children: selectedExercises.map((id) {
                          final ex = exercises.firstWhere((e) => e["id"] == id);
                          return Chip(
                            label: Text(ex["ExerciseName"], style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.greenAccent,
                            onDeleted: () => setModalState(() => selectedExercises.remove(id)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // select muscle
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[850],
                        decoration: InputDecoration(
                          labelText: "Select Muscle",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: null,
                        items: muscles.map((m) {
                          return DropdownMenuItem<String>(
                            value: m["id"],
                            child: Text(m["MuscleName"], style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && !selectedMuscles.contains(value)) {
                            setModalState(() => selectedMuscles.add(value));
                          }
                        },
                      ),
                      Wrap(
                        spacing: 6,
                        children: selectedMuscles.map((id) {
                          final m = muscles.firstWhere((m) => m["id"] == id);
                          return Chip(
                            label: Text(m["MuscleName"], style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.greenAccent,
                            onDeleted: () => setModalState(() => selectedMuscles.remove(id)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (planToEdit == null) {
                      await _service.createTrainingPlan(
                        name: nameController.text,
                        description: descController.text,
                        Exercises: selectedExercises,
                        Muscles: selectedMuscles,
                      );
                    } else {
                      await _service.updateTrainingPlan(
                        planToEdit["id"],
                        nameController.text,
                        descController.text,
                        selectedExercises,
                        selectedMuscles,
                      );
                    }

                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text(planToEdit == null ? "Save" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _styledInput({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
      ),
    );
  }
}
