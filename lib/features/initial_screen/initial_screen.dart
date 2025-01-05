import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:confirma_id/features/initial_screen/initial_popup.dart';
import 'package:confirma_id/features/login/login_screen.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatefulWidget {
  final String logoPath; // Caminho da logo

  // Construtor com parâmetros para altura da logo, caminho da logo, altura da área cinza escuro e posições dos botões
  const InitialScreen({
    this.logoPath = 'lib/components/logo.png', // Caminho padrão da logo
  });

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    showPopup(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = Database().getIsUserLoggedIn();

    // Obtém as dimensões da tela
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define a largura e a altura da logo com base nas dimensões da tela
    final double logoWidth = screenWidth * 0.7; // 70% da largura da tela
    final double logoHeight = screenHeight * 0.2; // 20% da altura da tela
    final double sizedBoxHeight = screenHeight * 0.1; // 10% da altura da tela

    bool authenticated = false;

    if (Database().getIsUserLoggedIn()) {
      authenticated = Database().getCurrentUserData()!['autenticado'] as bool;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightBackgroundColor,
      ),
      backgroundColor: lightBackgroundColor, // Cinza claro
      body: Column(
        children: [
          // Parte superior com a logo
          Center(
            child: Image.asset(
              widget.logoPath, // Usando o caminho da logo passado como parâmetro
              width: logoWidth,
              height: logoHeight, // Usando a altura da logo passada como parâmetro
            ),
          ),
          const SizedBox(height: 20), // Espaço entre a logo e o container
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: darkBackgroundColor, // Cinza escuro
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 150), // Espaço antes do primeiro botão
                        // Botão "Verificar"
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profileSearch');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor, // Cor de fundo do botão
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Verificar',
                            style: elevatedButtonTextStyle,
                          ),
                        ),
                        SizedBox(height: sizedBoxHeight), // Espaço entre os botões
                        // Botão "Fazer autenticação" com uma palavra por linha
                        if (!loggedIn)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/login',
                                arguments: const LoginScreen(isLogin: true,),
                              ).then((value) => setState(() {}));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor, // Cor de fundo do botão
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Entrar'),
                                ],
                              ),
                              textAlign: TextAlign.center, // Centraliza o texto
                              style: elevatedButtonTextStyle,
                            ),
                          ) 
                        else 
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                authenticated ? '/dataManage' : '/authReq',
                              ).then((value) => setState(() {}));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor, // Cor de fundo do botão
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Cadastrar Dados'),
                                ],
                              ),
                              textAlign: TextAlign.center, // Centraliza o texto
                              style: elevatedButtonTextStyle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
