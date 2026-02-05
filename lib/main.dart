import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Se tiver usando fontes
import 'package:payer_payment/app/views/home_page.dart';
// Importe o caminho correto da sua HomePage

void main() {
  // CORREÇÃO: Chamamos o MyApp (a Fundação), não a HomePage direto.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payer Payment',
      debugShowCheckedModeBanner: false, // Tira a faixa "Debug" do canto
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0056D2)),
      ),
      // AQUI conectamos a HomePage
      home: const HomePage(),
    );
  }
}
