import 'package:confirma_id/components/shared/exceptions.dart';
import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:confirma_id/features/profile_search/profile_list.dart';
import 'package:confirma_id/features/profile_verification_screen/profile_verification_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

const String profileSearchTitle = 'Buscar Perfil';
const String textFieldText = 'Digite o nome do usuário';

class ProfileSearchScreen extends StatefulWidget {
  @override
  _ProfileSearchScreenState createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  Future<List<Profile>>? _filteredProfiles;
  String _userInput = '';

  Future<List<Profile>> getFilteredProfiles(
      String userInput, BuildContext context,) async {
    final List<Profile> tempProfiles = [];

    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none && mounted) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
      // ignore: use_build_context_synchronously
      context.showSnackBar('Por favor, conecte-se à internet para buscar perfis.');
      throw NoInternetException('Por favor, conecte-se à internet para buscar perfis.');
    }

    try {
      final List<Map<String, dynamic>> data = await Database().searchForUser(userInput);

      for (final Map<String, dynamic> profile in data) {
        if (profile['autenticado'] as bool) {
          tempProfiles.add(
              Profile(
                name: (profile['full_name'] ?? '') as String,
                uniqueID: (profile['id'] ?? '') as String,
                registerNumber: (profile['register_number'] ?? '').toString(),
                imageUrl: (profile['avatar_url'] ?? '') as String,
                onTapOveride: () => _onTapProfile(context, (profile['id'] ?? '') as String),
              ),
            );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (mounted) context.showSnackBar('Ocorreu um erro durante a pesquisa, por favor tente novamente.');
      rethrow;
    }
    
    
    return tempProfiles;
  }

  void _onTapProfile(BuildContext context, String userId) {
    Navigator.pushNamed(
      context,
      '/verify',
      arguments:
          ProfileVerificationArguments(userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(profileSearchTitle),
        backgroundColor: darkBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: textFieldText,
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: lightBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _userInput = query;
                  _filteredProfiles = getFilteredProfiles(_userInput, context);
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              // Use o FutureBuilder para lidar com dados assíncronos
              child: FutureBuilder<List<Profile>>(
                future: _filteredProfiles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.error is NoInternetException || snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhum perfil encontrado.');
                  } else {
                    return ProfileList(profiles: snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
