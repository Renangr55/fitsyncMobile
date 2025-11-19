import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Widget> fotosCarrosel = [
  Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 5),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset("assets/image/firstBanner.jpg", fit: BoxFit.cover),
    ),
  ),
  Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 3),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset("assets/image/secondBanner.jpg", fit: BoxFit.cover),
    ),
  ),
];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: const Color.fromARGB(255, 15, 15, 15),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Hello",
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    Text(
                      "Gym Rat",
                      style: TextStyle(color: Colors.green, fontSize: 50),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

         
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.30, //mexendo com responsividade
                  child: CarouselSlider(
                    items: fotosCarrosel,
                    options: CarouselOptions(
                      autoPlayInterval: const Duration(seconds: 2),
                      autoPlay: true,
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
