import 'dart:async';

import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Compartilhado
const String emailLabel = 'Email';
const String passwordLabel = 'Senha';

// Login
const String loginMessage =
    'Para continuar, realize seu login';
const String loginButtonText = 'Fazer Login';
const String loginText = 'Fazendo login...';

// SignUp
const String signUpMessage =
    'Para continuar, crie a sua conta\nAtenção: o nome completo deve ser idêntico ao presente em sua assinatura digital do Gov.br';
const String fullNameLabel = 'Nome completo';
const String cpfLabel = 'CPF';
const String creatingText = 'Criando conta...';
const String signUpButtonText = 'Criar conta';
const String checkEmailMessage =
    'Verifique o link de autenticação no seu email!';

const String authErrorMessage = 'Ocorreu um erro durante a criação, tente novamente mais tarde!';
const String unexpectedErrorMessage = 'Ocorreu um erro inesperado, tente novamente mais tarde';

class LoginScreen extends StatefulWidget {
  final bool isLogin;

  const LoginScreen({super.key, required this.isLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _fullNameController = TextEditingController();
  late final TextEditingController _cpfController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;
  final maskCpf = MaskTextInputFormatter(mask: "###.###.###-##", filter: {"#": RegExp('[0-9]')});

  bool _verifyCpf(String cpf) {

    final String cpfTrim = cpf.replaceAll('-', '').replaceAll('.', '');

    const List<String> blacklist = [
      "00000000000",
      "11111111111",
      "22222222222",
      "33333333333",
      "44444444444",
      "55555555555",
      "66666666666",
      "77777777777",
      "88888888888",
      "99999999999",
      "12345678909",
    ];

    if (blacklist.contains(cpfTrim)) return false;

    int firstSum = 0;
    int secondSum = 0;
    String remainders = '';


    for (int i = 0; i < cpfTrim.length - 2; i++) {
      firstSum += int.parse(cpfTrim[i]) * (10 - i);
      secondSum += int.parse(cpfTrim[i]) * (11 - i);
    }

    int r = firstSum % 11;

    remainders += (r < 2 ? 0 : 11 - r).toString();

    if (remainders != cpfTrim[9]) return false;

    secondSum += int.parse(remainders) * 2;

    r = secondSum % 11;

    remainders += (r < 2 ? 0 : 11 - r).toString();
    
    return cpfTrim.substring(9,11) == remainders;
  }

  Future<void> _signIn() async {
    final Database database = Database();
    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none && mounted) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
      context
          .showSnackBar('Por favor, conecte-se à internet para se autenticar.');
    } else {
      if ((widget.isLogin &&
                  (_emailController.text.trim() == '' ||
                      _passwordController.text.trim() == '') ||
              !widget.isLogin &&
                  (_emailController.text.trim() == '' ||
                      _passwordController.text.trim() == '' ||
                      _fullNameController.text.trim() == '' ||
                      _cpfController.text.trim() == '')) &&
          mounted) {
        context.showSnackBar('Você deve inserir dados válidos!');
      } else {
        try {
          setState(() {
            _isLoading = true;
          });
          if (widget.isLogin) {
            await database.signInUser(_emailController.text.trim(), _passwordController.text);
          } else {
            if (!_verifyCpf(_cpfController.text.trim())) {
              if (mounted) context.showSnackBar('Insira um CPF válido.');
            } else {
              final response = await database.signUpUser(_emailController.text.trim(), _passwordController.text, _fullNameController.text.trim(), _cpfController.text.trim());
              if (response.user!.identities!.isEmpty && mounted) {
                context.showSnackBar(
                    'Este email já está registrado.',);
              } else if (!widget.isLogin && mounted) {
                context.showSnackBar(checkEmailMessage);
              }
              if (mounted) {
                _emailController.clear();
                _passwordController.clear();
              }
            }
          }
          
        } on AuthException catch (e) {
            switch (e.code) {
            case 'weak_password':
              if (mounted) context.showSnackBar('Insira uma senha de no mínimo 6 caracteres.');
            default:
              if (mounted) context.showSnackBar(authErrorMessage, isError: true);
            }
        } catch (error) {
          if (mounted) {
            context.showSnackBar(unexpectedErrorMessage, isError: true);
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    final Database database = Database();
    _authStateSubscription = database.listenToAuthChange(
      (data) async {
        if (_redirecting) return;
        final session = data.session;
        if (session != null) {
          _redirecting = true;
          if (mounted) {
            await Database().loadCurrentUserData();
            if (mounted) Navigator.of(context).pop();
          }
        }
      },
      onError: (error) {
        if (!mounted) return;
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar(unexpectedErrorMessage, isError: true);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as dimensões da tela
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define a largura e a altura da logo com base nas dimensões da tela
    final double logoWidth = screenWidth * 0.7; // 70% da largura da tela
    final double logoHeight = screenHeight * 0.2; // 20% da altura da tela

    final String instructionMessage = widget.isLogin ? loginMessage : signUpMessage;

    final String buttonText = _isLoading
        ? widget.isLogin
            ? loginText
            : creatingText
        : widget.isLogin
            ? loginButtonText
            : signUpButtonText; 
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightBackgroundColor,
      ),
      backgroundColor: lightBackgroundColor, // Cinza claro
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Parte superior com a logo
                Center(
                  child: Image.asset(
                    'lib/components/logo.png',
                    width: logoWidth,
                    height: logoHeight, // Altura da logo
                  ),
                ),
                const SizedBox(height: 20), // Espaço entre a logo e o container
                // Parte inferior com a cor cinza escuro
                Expanded(
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
                        const SizedBox(
                          height: 60,
                        ),
                        Text(
                          instructionMessage,
                          textAlign: TextAlign.center,
                          style: commomTextStyle,
                        ),
                        const SizedBox(height: 18),
                        if (!widget.isLogin)
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: fullNameLabel,
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: lightBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        const SizedBox(height: 18),
                        if (!widget.isLogin)
                          TextFormField(
                            controller: _cpfController,
                            inputFormatters: [maskCpf],
                            decoration: const InputDecoration(
                              labelText: cpfLabel,
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: lightBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: emailLabel,
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: lightBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: passwordLabel,
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: lightBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                buttonColor, // Cor de fundo do botão
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 20,
                              color: buttonTextColor, // Cor do texto
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (widget.isLogin) 
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  '/login',
                                  arguments: const LoginScreen(isLogin: false,),
                                ).then((value) => setState(() {}));
                            },
                            child: const Text(
                              'Criar conta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
