import 'package:flutter/material.dart';

// Classe que define os argumentos necessários para a tela
class NotConfereArguments {
  final String updatedAt;

  NotConfereArguments(this.updatedAt);
}

class NotConfereScreen extends StatelessWidget {
  final String updatedAt;

  const NotConfereScreen({required this.updatedAt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE42C2C), // Cor de fundo
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFE42C2C), // Cor do AppBar igual ao fundo
        elevation: 0, // Remove a sombra do AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        // Centraliza todo o conteúdo vertical e horizontalmente
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Margens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Símbolo de X
              const Icon(
                Icons.clear, // Ícone de X
                size: 300,
                color: Colors.white,
              ),
              const SizedBox(height: 40), // Espaçamento entre o ícone e o texto
              // Texto
              const Text(
                "O dado NÃO confere com o informado pelo usuário",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5, // Espaçamento entre as linhas
                ),
                textAlign: TextAlign.center, // Centraliza o texto
              ),
              const SizedBox(height: 20), // Espaçamento entre o texto e a data
              Text(
                "Dado informado no dia: $updatedAt",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
