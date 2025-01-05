import 'package:confirma_id/components/shared/styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentIndex = 0;
  final int _totalPages = 6;

  // Função para salvar a conclusão do tutorial
  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialCompleted', true);
  }

  // Função para mudar para a próxima imagem ou finalizar o tutorial
  Future<void> _nextPage() async {
    setState(() {
      if (_currentIndex < _totalPages - 1) {
        _currentIndex++;
      } else {
        _completeTutorial();
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  // Função para mudar para a imagem anterior
  void _previousPage() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: Stack(
        children: [
          if (_currentIndex < _totalPages)
            Positioned.fill(
              child: Image.asset(
                'lib/features/tutorial/tutorial_images/tutorial${_currentIndex + 1}.png',
                fit: BoxFit.contain,
              ),
            ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentIndex == index ? 12.0 : 8.0,
                  height: _currentIndex == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              heroTag: "btn1",
              onPressed: _nextPage,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Visibility(
              visible: _currentIndex > 0,
              child: FloatingActionButton(
                heroTag: "btn2",
                onPressed: _previousPage,
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
