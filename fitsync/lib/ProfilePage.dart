import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Perfil do Usuário",
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}