import 'package:flutter/material.dart';

class NoInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBAF22), // Cor de fundo
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFDBAF22), // Cor do AppBar igual ao fundo
        elevation: 0, // Remove a sombra do AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        // Centraliza todo o conteúdo vertical e horizontalmente
        child: Padding(
          padding: EdgeInsets.all(20.0), // Margens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Símbolo de menos
              Icon(
                Icons.remove, // Ícone de menos
                size: 300,
                color: Colors.white,
              ),
              SizedBox(height: 20), // Espaçamento entre o ícone e o texto
              // Texto
              Text(
                "O sistema não possui essa informação",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5, // Espaçamento entre as linhas
                ),
                textAlign: TextAlign.center, // Centraliza o texto
              ),
            ],
          ),
        ),
      ),
    );
  }
}
