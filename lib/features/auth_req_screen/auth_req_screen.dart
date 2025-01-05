import 'package:confirma_id/components/shared/avatar.dart';
import 'package:confirma_id/components/shared/generic_screen_layout.dart';
import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/auth_req_screen/notification_handler.dart';
import 'package:confirma_id/features/auth_req_screen/signature_verifier.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Tela principal de gerenciamento de dados
class AuthReqScreen extends StatefulWidget {

  const AuthReqScreen({
    super.key,
  });

  @override
  State<AuthReqScreen> createState() => _AuthReqScreenState();
}

class _AuthReqScreenState extends State<AuthReqScreen> {
  String? _avatarUrl;
  final _userDataController = TextEditingController();
  Map<String, dynamic>? _profileData;
  var _loading = true;
  bool profileAuth = false;
  String fullName = '';
  static const String receiveButtonText = 'Receber Declaração';
  static const String sendButtonText = 'Enviar Declaração Assinada';

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

  Future<void> _onValidDecl() async {
    final Database database = Database();
    try {
      database.updateCurrentUserProfile({
        'autenticado': true,
      });
      if (mounted) context.showSnackBar('Declaração verificada com sucesso!');
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
      _profileData?['autenticado'] = true;
      profileAuth = true;
    });

    Navigator.pop(context);
  }

  // Função para enviar declaração de abertura de conta ao usuário
  Future<void> _sendDeclToUser() async {
    try {
      final bool response = await NotificationHandler.sendNotification(
          userId: Database().getCurrentUser()!.id, userEmail: _profileData!['email_login'] as String, notificationId: 'declaracao',);
      if (response && mounted) context.showSnackBar('Declaração enviada com sucesso!',);
    } on NotificationException catch (e) {
      if (mounted) context.showSnackBar(e.message, isError: true);
    } catch (e) {
      if (mounted) context.showSnackBar('Ocorreu um erro inesperado, tente novamente mais tarde!', isError: true);
    }
  }

  Future<void> _recvSignedDecl() async {
    // Inicia seleção do arquivo de declaração por parte do usuário
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    // Caso não for possível obter o arquivo, informa o usuário
    if (result == null) {
      if (mounted) context.showSnackBar('Não foi possível obter a declaração.',);
      return;
    }

    final file = result.files.first;

    if (file.extension != 'pdf' && mounted) {
      context.showSnackBar('A declaração precisa ser um PDF, selecione outro arquivo!',);
      return;
    }

    int sigVerifierResponse;

    if (file.path == null) {
      if (mounted) context.showSnackBar('Não foi possível acessar a declaração!', isError: true);
      return;
    }

    try {
      sigVerifierResponse = await SignatureVerifier.verifySignature(
      signedFile: file.path!,
      fullName: _profileData!['full_name'] as String,
      cpf: _profileData!['cpf'] as String,
      );
    } on SignatureVerifierException catch (e) {
      if (mounted) context.showSnackBar(e.message, isError: true);
      return;
    } catch (e) {
      if (mounted) context.showSnackBar('Ocorreu um erro inesperado, tente novamente mais tarde!', isError: true);
      return;
    }

    switch (sigVerifierResponse) {
      case 0:
        _onValidDecl();
      case 1:
        if (mounted) {
          context.showSnackBar('A requisição deve ser assinada pelo mesmo usuário da conta ConfirmaId!');
        }
      case 2:
        if (mounted) {
          context.showSnackBar('Assinatura inválida.', isError: true);
        }
      default:
        if (mounted) context.showSnackBar('Erro desconhecido!', isError: true);
    }

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

  Widget _buildAuthReq() {
    const String needAuthText =
        'Para cadastrar seus dados, autentique-se ao seguir os passos abaixo';
    const List<String> authSteps = [
      'Ao clicar em "$receiveButtonText", será enviado um arquivo de declaração de abertura de conta ao email cadastrado;',
      'Assine a declaração por meio do Gov.br ou Assina Ufsc;',
      'Informe a declaração assinada por meio do botão "$sendButtonText"',
    ];
    return Column(
      children: [
        const Center(
          child: Text(
            needAuthText,
            textAlign: TextAlign.center,
            style: commomTextStyle,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: authSteps.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.circle, color: Colors.white, size: 10),
              title: Transform.translate(
                offset: const Offset(-16, 0),
                child: Text(
                  textAlign: TextAlign.justify,
                  authSteps[index],
                  style: commomTextStyle,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _sendDeclToUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            receiveButtonText,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _recvSignedDecl,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            sendButtonText,
            style: TextStyle(
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
        _loading ? const CircularProgressIndicator() : _buildAuthReq();

    return genericScreenLayout(
      context,
      'Verificação',
      Center(
        child: Avatar(
          imageUrl: _avatarUrl,
          onUpload: (String a) {},
          isDataUpdate: false,
          fullName: fullName,
        ),
      ),
      body,
    );
  }
}
