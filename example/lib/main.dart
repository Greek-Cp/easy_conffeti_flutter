import 'dart:math' as math;
import 'package:easy_conffeti/easy_conffeti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Confetti Designer',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Playground'),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfettiDesignerPage()),
          );
        },
        child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.blueAccent.shade200,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.design_services,
                  color: Colors.white,
                ),
                FittedBox(
                    child: Text(
                  "Live Editor",
                  style: TextStyle(color: Colors.white),
                ))
              ],
            )),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ConfettiHelper.showConfettiDialog(
              context: context,
              confettiType: ConfettiType.success,
              confettiStyle: ConfettiStyle.paper,
              animationStyle: AnimationConfetti.explosion,
              colorTheme: ConfettiColorTheme.red,
              density: ConfettiDensity.medium,
              durationInSeconds: 5,
              message: "Success! ✅",
              cardDialog: QuizFailedCard(
                message: "Congratulation You Already Complete The Quiz",
                score: "20",
              ),
              isColorMixedFromModel: true,
            );
          },
          child: Text('Show Confetti'),
        ),
      ),
    );
  }
}
