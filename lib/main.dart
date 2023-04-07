import 'package:flutter/material.dart';
import 'package:quotes_categories_database/views/screens/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home_Page(),
    ),
  );
}
