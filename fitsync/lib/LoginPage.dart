import 'package:fitsync/Homepage.dart';
import 'package:flutter/material.dart';
import 'MainNavigationBar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {

  TextEditingController user = TextEditingController();
  TextEditingController password = TextEditingController();

  String correctUser = "Renan";
  String correctPassword = "text";
  String error = "";

  void login(){
    print("text");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
        width: double.infinity, //maneira mais facil de falar 100%
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
          image: AssetImage('assets/image/gymPhoto.jpg'),
          opacity: 0.2,
          scale: 1.0,
          fit: BoxFit.cover,
        ),),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: 400,
                // fitSync
                child: Image.asset('assets/image/logo.png'),
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                      width: 300,
                      child: TextField(
                        style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                        controller: user,
                        maxLength: 30,
                        decoration: InputDecoration(
                          counterStyle: TextStyle(
                            color: Colors.green
                          ),
                          label: Text("type the your name",style: TextStyle(color: Colors.white),),
                          hintText: "Ex: Renan Gabriel",
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ), focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green, width: 2.0),
                          )
                          
                        ),
                      ),
                    ),SizedBox(height: 10,),
                    SizedBox(
                      height: 70,
                      width: 300,
                      child: TextField(
                        style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                        cursorColor: Colors.green,
                        obscureText: true,
                        controller: password,
                        maxLength: 30,
                        decoration: InputDecoration(
                          counterStyle: TextStyle(
                            color: Colors.green
                          ),
                          hintText: "e.g.: *awpojihewbn#aa",
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          label: Text("Type your the password",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ), 
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green, width: 2.0),
                          )
                        ),
                      ),
                    )
                  ],
                ),
              ),

              ElevatedButton(onPressed: (){
                login();
                  Navigator.push(
                  context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),

                );
              },style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 6, 185, 87),
                foregroundColor: Colors.white
              ) , child: Text('Sign in')),
            ],
          ),
        ),
      ),
    );
  }
}