import 'package:cloud_firestore/cloud_firestore.dart';

class ExercicioService {
  final _db = FirebaseFirestore.instance;


  Future<List<Map<String, dynamic>>> getExecise() async {
    try {
      final snap = await _db.collection("Exercise").get();

      // Como vamos usar await dentro do map:
      return await Future.wait(
        snap.docs.map((doc) async {
          final data = doc.data();

          // Referência do músculo
          final DocumentReference? muscleRef = data["TypeMuscle"];

          Map<String, dynamic>? muscleData;

          // Busca o documento do músculo
          if (muscleRef != null) {
            final muscleSnap = await muscleRef.get();
            muscleData = muscleSnap.data() as Map<String, dynamic>?;
          }

          return {
            "id": doc.id,
            "ExerciseName": data["ExerciseName"]?.toString() ?? "No Name",
            "Repetition": data["Repetition"]?.toString() ?? "No Repetition",
            "Series": data["Series"]?.toString() ?? "No Series",

            // aqui agora vem só os dados do músculo
            "TypeMuscle": muscleData,
          };
        }).toList(),
      );
    } catch (e) {
      print("Erro ao buscar exercícios: $e");
      rethrow;
    }
  }
  //get muscle
  Future<List<Map<String, dynamic>>> getMuscle() async {
    try {
      final snap = await _db.collection("Muscle").get();

      return snap.docs.map((doc) {
        final data = doc.data();

        return {
          "id": doc.id,
          "MuscleName": data["MuscleName"]?.toString() ?? "Sem nome"
        };
      }).toList();
    } catch (e) {
      print("Erro ao buscar exercícios: $e");
      rethrow;
    }
  }

  //post muscle
  Future<void> postMuscle(Map<String, dynamic> data) async {
    try {
      await _db.collection("Muscle").add(data);
    } catch (e) {
      print("Error to save: $e");
    }
  }

  Future<void> createExercise({
  exerciseName,
  repetition,
  series,
  required String muscleId, // ← ID do músculo relacionado
  }) async {
    try {
      // Referência do músculo
      final muscleRef =
          _db.collection("Muscle").doc(muscleId);

      // Criar o exercício
      await _db.collection("Exercise").add({
        "ExerciseName": exerciseName,
        "Repetition": repetition,
        "Series": series,
        "TypeMuscle": muscleRef,   // ← salvando o relacionamento
      });

      print("Exercício criado com sucesso!");
    } catch (e) {
      print("Erro ao criar exercício: $e");
    }
  }

  Future<void> updateMuscle(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection("Muscle").doc(id).update(data);
      print("Muscle atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar muscle: $e");
    }
  }

  Future<void> updateExercise(String id, Map<String, dynamic> data) async {
    if (data.containsKey("muscleId")) {
      data["TypeMuscle"] = _db.collection("Muscle").doc(data["muscleId"]);
      data.remove("muscleId");
    }
    try {
      await _db.collection("Exercise").doc(id).update(data);
      print("Exercício atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar exercício: $e");
    }
  }

  Future<void> deleteMuscle(String id) async {
    try {
      await _db.collection("Muscle").doc(id).delete();
      print("Muscle deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar muscle: $e");
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await _db.collection("Exercise").doc(id).delete();
      print("Exercício deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar exercício: $e");
    }
  }

}
