// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAlertDialog extends StatefulWidget {
  @override
  _TermsAlertDialogState createState() => _TermsAlertDialogState();
}

class _TermsAlertDialogState extends State<TermsAlertDialog> {
  bool _isChecked = false;
  String popupText =
      'Bem-vindo ao aplicativo ConfirmaID! Este aplicativo foi desenvolvido para a disciplina de Segurança da Computação como parte de um trabalho em grupo. Antes de continuar, é necessário aceitar os Termos de Uso. Caso não aceite, infelizmente você não poderá utilizar o aplicativo.';

  _launchURL() async {
    final Uri url =
        Uri.parse('https://confirmaid.github.io/Termos-de-Uso.html');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Termo de Uso',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                popupText,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                  height: 1.5,
                  color: Colors.black,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _launchURL,
                child: const Text(
                  'Clique aqui para acessar os Termos',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width < 500 ? 24 : 48,
                    height: MediaQuery.of(context).size.width < 500 ? 24 : 48,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                  Text(
                    'Li e aceito os Termos de Uso.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 12 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isChecked
                    ? () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('acceptedTerms', true);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text(
                  'Continuar',
                  style: TextStyle(
                    color: _isChecked ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showPopup(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool acceptedTerms = prefs.getBool('acceptedTerms') ?? false;
  if (!acceptedTerms) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsAlertDialog();
      },
    );
  }
}
