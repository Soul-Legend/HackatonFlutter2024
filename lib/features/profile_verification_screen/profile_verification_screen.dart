import 'package:confirma_id/components/shared/avatar.dart';
import 'package:confirma_id/components/shared/data_select_dropdown.dart';
import 'package:confirma_id/components/shared/generic_screen_layout.dart';
import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/components/shared/utilities.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:confirma_id/features/results_screens/confere.dart';
import 'package:confirma_id/features/results_screens/notconfere.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Classe que define os argumentos necessários para a tela de gerenciamento de dados
class ProfileVerificationArguments {
  final String searchUserID;

  ProfileVerificationArguments(this.searchUserID);
}

// Tela principal de gerenciamento de dados
class ProfileVerificationScreen extends StatefulWidget {
  final String searchUserID;

  const ProfileVerificationScreen({
    super.key,
    required this.searchUserID,
  });

  @override
  State<ProfileVerificationScreen> createState() => _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  final maskPhone = MaskTextInputFormatter(mask: "(##) #####-####", filter: {"#": RegExp('[0-9]')});
  bool useMask = false;
  final String _textFieldText = 'Dado';
  String? _dataType;
  String? _avatarUrl;
  final _userDataController = TextEditingController();
  Map<String, dynamic>? _profileData;
  var _loading = true;
  bool _canVerify =
      true; // Controle para esperar 5 segundos após cada verificação
  bool profileAuth = false;
  String fullName = '';

  // Função para lidar com a mudança no dropdown
  void _handleDropdownChange(String? newValue) {
    setState(() {
      _dataType = newValue;
      if (_dataType != null && _dataType!.contains('phone')) {
        useMask = true;
        _userDataController.clear();
      } else {
        useMask = false;
        _userDataController.clear();
      }
    });
  }

  // Função para buscar o perfil do usuário no banco de dados
  Future<void> _getProfile(String userId) async {
    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none && mounted) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
      context
          .showSnackBar('Por favor, conecte-se à internet para buscar perfis.');
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = true; // Define o estado de carregamento como verdadeiro
      });
      try {
        // Busca o perfil do usuário na tabela 'profiles' onde o 'id' é igual ao userId fornecido
        _profileData = await Database().getUserProfile(userId);
        // Armazena a URL do avatar do perfil buscado
        _avatarUrl = _profileData!['avatar_url'] as String?;
        profileAuth = _profileData!['autenticado'] as bool;
        fullName = _profileData!['full_name'] as String;
      } catch (error) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.showSnackBar(
                'Ocorreu um erro inesperado, tente novamente mais tarde',
                isError: true,);
          });
        }
      } finally {
        // Define o estado de carregamento como falso após a conclusão da busca
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  // Função para fazer upload de uma nova imagem de avatar
  Future<void> _onUpload(String imageUrl) async {
    final Database database = Database();
    try {
      database.updateCurrentUserProfile({
        'avatar_url': imageUrl,
      });
      if (mounted) {
        const SnackBar(
          content: Text('Imagem de perfil atualizada!'),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSnackBar(
              'Ocorreu um erro inesperado, tente novamente mais tarde',
              isError: true,);
        });
      }
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _profileData?['avatar_url'] = imageUrl;
      _avatarUrl = imageUrl;
    });
  }

  // Função para verificar os dados do usuário
  Future<void> _verify() async {
    if (!_canVerify) {
      context.showSnackBar('Aguarde 5 segundos antes de verificar novamente.');
      return;
    }

    final String userData = _userDataController.text.trim();
    final String userDataHash = generateHash(userData);
    final String? profileDataHash = _profileData![_dataType] as String?;

    // Caso o usuário não tenha informado o dado, avisa-lo que deve ser informado
    if (userData == '') {
      if (mounted) {
        context.showSnackBar('Você deve inserir um dado para verifica-lo!');
      }
    } else if (_dataType == '' || _dataType == null) {
      if (mounted) {
        context
            .showSnackBar('Você deve escolher um tipo de dado para verificar!');
      }
    } else {
      setState(() {
        _canVerify = false;
      });
      if (profileDataHash == '' || profileDataHash == null) {
        Navigator.pushNamed(context, '/NoInfoScreen');
      } else {
        final String updatedAt = _profileData!['${_dataType}_update'] as String;
        final DateTime updatedAtDateTime = DateTime.parse(updatedAt);
        final String formattedDate = '${updatedAtDateTime.day.toString().padLeft(2, '0')}/${updatedAtDateTime.month.toString().padLeft(2, '0')}/${updatedAtDateTime.year}';
        if (userDataHash == profileDataHash) {
          Navigator.pushNamed(
            context,
            '/ConfereScreen',
            arguments: ConfereScreenArguments(formattedDate),
          );
        } else {
          Navigator.pushNamed(
            context,
            '/notConfere',
            arguments: NotConfereArguments(formattedDate),
          );
        }
      }
    }

    await Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _canVerify = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    final userId = widget.searchUserID;
    _getProfile(userId);
  }

  @override
  void dispose() {
    _userDataController.dispose();
    super.dispose();
  }

  Widget _buildVerifyData() {
    return Column(
      children: [
        DataSelectDropdown(onChanged: _handleDropdownChange),
        const SizedBox(height: 18),
        TextFormField(
          controller: _userDataController,
          inputFormatters: useMask ? [maskPhone]: [],
          decoration: InputDecoration(
            labelText: _textFieldText,
            labelStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: lightBackgroundColor,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _loading ? 'Verificando...' : 'Verificar',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body =
        _loading ? const CircularProgressIndicator() : _buildVerifyData();

    return genericScreenLayout(
      context,
      'Verificação',
      Center(
        child: Avatar(
          imageUrl: _avatarUrl,
          onUpload: _onUpload,
          isDataUpdate: false,
          fullName: fullName,
        ),
      ),
      body,
    );
  }
}
