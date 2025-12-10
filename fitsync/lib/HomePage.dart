import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/exercicio_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ExercicioService _exercicioService = ExercicioService();
  List<dynamic> exercicios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarExercicios();
  }

  Future<void> carregarExercicios() async {
    try {
      final lista = await _exercicioService.getMuscle();
      if (!mounted) return;

      setState(() {
        exercicios = lista;
        loading = false;
      });
    } catch (e) {
      print("Erro: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Welcome to FitApp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: CarouselSlider(
                  items: [
                    cardBanner("assets/image/firstBanner.jpg"),
                    cardBanner("assets/image/secondBanner.jpg"),
                  ],
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 0.85,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Exercícios",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                    )
                  : exercicios.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum exercício disponível",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: exercicios.length,
                          itemBuilder: (context, index) {
                            return cardExercicio(exercicios[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardBanner(String img) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(img, fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  Widget cardExercicio(dynamic ex) {
    final descricao = (ex["descricao"]?.toString().trim().isNotEmpty == true)
        ? ex["descricao"]
        : "No description";

    final muscles = (ex["muscles"] as List<dynamic>?)
            ?.map((m) => m.toString())
            .join(" • ") ??
        "No muscles";

    return Card(
      color: const Color.fromARGB(50, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          ex["nome"] ?? "Exercício",
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              muscles,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ],
        ),
        trailing: const Icon(Icons.fitness_center, color: Colors.greenAccent),
      ),
    );
  }
}
