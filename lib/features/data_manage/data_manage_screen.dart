import 'package:confirma_id/components/shared/avatar.dart';
import 'package:confirma_id/components/shared/data_select_dropdown.dart';
import 'package:confirma_id/components/shared/generic_screen_layout.dart';
import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/components/shared/utilities.dart';
import 'package:confirma_id/features/data_manage/data_manage_popup.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Tela principal de gerenciamento de dados
class DataManageScreen extends StatefulWidget {
  const DataManageScreen({
    super.key,
  });

  @override
  State<DataManageScreen> createState() => _DataManageScreenState();
}

class _DataManageScreenState extends State<DataManageScreen> {
  final maskPhone = MaskTextInputFormatter(mask: "(##) #####-####", filter: {"#": RegExp('[0-9]')});
  bool useMask = false;
  final String _textFieldText = 'Dado';
  String? _dataType;
  String? _userDataType;
  String? _avatarUrl;
  final _userDataController = TextEditingController();
  Map<String, dynamic>? _profileData;
  var _loading = true;
  bool profileAuth = false;
  String fullName = '';

  final Map<String,String> _dropdownItems = {
    'discord_hash' : 'Discord',
    'instagram_hash' : 'Instagram',
    'personal_phone_hash' : 'Telefone Pessoal',
    'prof_phone_hash' : 'Telefone Profissional',
    'personal_email' : 'Email Pessoal',
    'prof_email' : 'Email Profissional',
  };

  // Função para lidar com a mudança no dropdown
  void _handleDropdownChange(String? newValue) {
    setState(() {
      _dataType = newValue;
      _userDataType = _dropdownItems[newValue];
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
  Future<void> _getProfile() async {
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
        _profileData = Database().getCurrentUserData();
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

  // Função para atualizar o perfil do usuário no banco de dados
  Future<void> _updateProfile() async {
    final bool? userConfirmation;
    if (_dataType == null || _dataType == '') {
      if (mounted) {
        context.showSnackBar(
          'Escolha o tipo do dado que você deseja informar.',);
      }
      return;
    } else  if (_userDataController.text.trim().isEmpty) {
      if (mounted) {
        context.showSnackBar(
          'Informe um dado válido.',);
      }
      return;
    } else {
      userConfirmation = await showDataManagePopup(context, _userDataType!, _userDataController.text.trim());
    }

    if (userConfirmation == null ||
      !userConfirmation) {
      if (mounted) {
        context.showSnackBar(
          'O dado não foi atualizado.',);
      }
      return;
    }

    final Database database = Database();
    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none && mounted) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
        context.showSnackBar(
            'Por favor, conecte-se à internet para atualizar seu perfil.',);
    } else {
      setState(() {
        _loading = true; // Define o estado de carregamento como verdadeiro
      });

      // Obtém o novo dado inserido pelo usuário e gera um hash desse dado
      final newData = _userDataController.text.trim();
      final newDataHash = generateHash(newData);
      // Cria um mapa com as atualizações a serem feitas no perfil do usuário
      final updates = {
        _dataType: newDataHash,
        '${_dataType}_update': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      try {
        await database.updateCurrentUserProfile(updates);
        if (mounted) context.showSnackBar('Perfil atualizado com sucesso!');
      } catch (error) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.showSnackBar(
                'Ocorreu um erro inesperado, tente novamente mais tarde',
                isError: true,);
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _loading = false;
            _dataType = null;
          });
        }
      }
    }
  }

  // Função para fazer logout do usuário
  Future<void> _signOut() async {
    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none && mounted) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
      context.showSnackBar(
          'Por favor, conecte-se à internet para sair corretamente.',);
    } else {
      try {
        await Database().signOut();
      } catch (error) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.showSnackBar(
                'Ocorreu um erro inesperado, tente novamente mais tarde',
                isError: true,);
          });
        }
      } finally {
        if (mounted) {
          Navigator.pop(context);
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

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _userDataController.dispose();
    super.dispose();
  }

  Widget _buildRegisterData() {
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
          onPressed: _loading ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _loading ? 'Salvando...' : 'Atualizar',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _signOut,
          child: const Text(
            'Encerrar sessão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body =
        _loading ? const CircularProgressIndicator() : _buildRegisterData();

    return genericScreenLayout(
      context,
      'Cadastrar Dados',
      Center(
        child: Avatar(
          imageUrl: _avatarUrl,
          onUpload: _onUpload,
          isDataUpdate: true,
          fullName: fullName,
        ),
      ),
      body,
    );
  }
}
