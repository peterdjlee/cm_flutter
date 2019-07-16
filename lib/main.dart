import 'package:cm_flutter/screens/view_teams_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CM',
      home: ViewTeamsScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CM',
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.85),
        elevation: 1.0,
      ),
      body: Container(),
    );
  }
}