import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String publishedAt;
  final String sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']?['name'] ?? '',
    );
  }
}

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


  // Train Plan
  Future<List<Map<String, dynamic>>> getTrainingPlans() async {
    final snap = await _db.collection("TrainingPlan").get();

    return await Future.wait(
      snap.docs.map((doc) async {
        final data = doc.data();

        // Referências
        final List exercisesRefs = data["Exercises"] ?? [];
        final List musclesRefs = data["Muscles"] ?? [];

        // Buscar nome dos exercícios
        final exercisesData = await Future.wait(exercisesRefs.map((ref) async {
          if (ref == null) return null;
          final snap = await (ref as DocumentReference).get();
          final d = snap.data() as Map<String, dynamic>?;
          return d?["ExerciseName"] ?? "No name";
        }));

        // Buscar nome dos músculos
        final musclesData = await Future.wait(musclesRefs.map((ref) async {
          if (ref == null) return null;
          final snap = await (ref as DocumentReference).get();
          final d = snap.data() as Map<String, dynamic>?;
          return d?["MuscleName"] ?? "No name";
        }));

        return {
          "id": doc.id,
          "Name": data["Name"],
          "Description": data["Description"],
          "Exercises": exercisesData, // nomes!
          "Muscles": musclesData,     // nomes!
        };
      }),
    );
  }

  //create Training Plan
  Future<void> createTrainingPlan({
    required String name,
    required String description,
    required List<String> Exercises, // Lista de IDs de exercícios
    required List<String> Muscles,   // Lista de IDs de músculos
  }) async {
    try {
      await _db.collection("TrainingPlan").add({
        "Name": name,
        "Description": description,

        // Campo chama Exercises (com S), mas busca na coleção Exercise (sem S)
        "Exercises": Exercises
            .map((id) => _db.collection("Exercise").doc(id))
            .toList(),

        // Campo chama Muscles (com S), mas busca na coleção Muscle (sem S)
        "Muscles": Muscles
            .map((id) => _db.collection("Muscle").doc(id))
            .toList(),
      });

      print("Plano de treino criado com sucesso!");
    } catch (e) {
      print("Erro ao criar plano de treino: $e");
    }
  }

  Future<void> deleteTrainingPlan(String id) async {
    await _db.collection("TrainingPlan").doc(id).delete();
  }

  // Update Training Plan
  Future<void> updateTrainingPlan(
    String planId,
    String name,
    String description,
    List<String> exercises, // Lista de IDs de exercícios
    List<String> muscles,   // Lista de IDs de músculos
  ) async {
    try {
      await _db.collection("TrainingPlan").doc(planId).update({
        "Name": name,
        "Description": description,
        "exercises": exercises.map((id) => _db.collection("Exercise").doc(id)).toList(),
        "muscles": muscles.map((id) => _db.collection("Muscle").doc(id)).toList(),
      });

      print("Plano de treino atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar plano de treino: $e");
    }
  }




Future<List<NewsArticle>> fetchHealthNews() async {
  final url = Uri.parse('https://saurav.tech/NewsAPI/top-headlines/category/health/in.json');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final articles = data['articles'] as List;

    return articles.map((json) => NewsArticle.fromJson(json)).toList();
  } else {
    throw Exception('Falha ao carregar notícias');
  }
}


}
