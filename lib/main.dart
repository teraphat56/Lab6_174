import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teraphat174_6/screen/display.dart';

import 'screen/formscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 

 
  @override
  Widget build(BuildContext context) {
  
    return DefaultTabController(
      length:2,
      child: Scaffold(
        body: TabBarView(
          children: [
            Formscreen (),
            DisplayScreen(),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 138, 224, 174),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(text: "บันทึกคะเเนน"),
            Tab(text: "รายชื่อนักเรียน"),
      ],
        labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
        labelColor: Color.fromARGB(255, 255, 255, 255),
      ),  
      ),
    );
  }
}

