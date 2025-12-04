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
      final lista = await _exercicioService.getExercicios();
      setState(() {
        exercicios = lista;
        loading = false;
      });
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: const Color.fromARGB(255, 15, 15, 15),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello",
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
              const Text(
                "Gym Rat",
                style: TextStyle(color: Colors.green, fontSize: 50),
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
                      autoPlayInterval: const Duration(seconds: 2),
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                    : ListView.builder(
                        itemCount: exercicios.length,
                        itemBuilder: (context, index) {
                          final ex = exercicios[index];
                          return cardExercicio(ex);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardBanner(String img) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(img, fit: BoxFit.cover),
      ),
    );
  }

  // 🔥 AQUI: card ajustado para seu novo Service
 
  Widget cardExercicio(dynamic ex) {

  final descricao = (ex["descricao"]?.toString().trim().isNotEmpty == true)
      ? ex["descricao"]
      : "No description";

  final muscles = (ex["muscles"] as List<dynamic>?)
        ?.map((m) => m.toString())
        .join(" • ") ??
    "No muscles";

  return Card(
    color: Colors.white12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 5,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: ListTile(
      title: Text(
        muscles,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            descricao,
            style: const TextStyle(color: Colors.white70),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            muscles,
            style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

}
