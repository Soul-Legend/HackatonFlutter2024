import 'package:confirma_id/components/shared/snackbar.dart';
import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
    required this.isDataUpdate,
    required this.fullName,
  });

  final String? imageUrl;
  final void Function(String) onUpload;
  final bool isDataUpdate;
  final String fullName;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;
  final double _widgetWidth = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
          Container(
            width: _widgetWidth,
            height: _widgetWidth,
            color: Colors.grey,
            child: Center(
              child: Icon(
                Icons.person,
                size: _widgetWidth / 2, // Tamanho do ícone
                color: Colors.white, // Cor do ícone
              ),
            ),
          )
        else
          Image.network(
            widget.imageUrl!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        if (widget.isDataUpdate)
          ElevatedButton(
            onPressed: _isLoading ? null : _upload,
            child: const Text(
              'Upload',
              style: TextStyle(color: Colors.white),
            ),
          ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            widget.fullName,
            style: commomTextStyle,
          ),
        ),
      ],
    );
  }

  Future<void> _upload() async {
    // Verificar a conectividade
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Mostrar uma mensagem de erro se não estiver conectado à internet
      if (mounted) context.showSnackBar('Por favor, conecte-se à internet para atualizar seu perfil.');
    } else {
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (imageFile == null) {
        return;
      }
      setState(() => _isLoading = true);

      try {
        final bytes = await imageFile.readAsBytes();
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = fileName;
        final imageUrlResponse = await Database().updateAvatar(filePath, bytes, imageFile.mimeType);
        widget.onUpload(imageUrlResponse);
      } on StorageException catch (error) {
        if (mounted) {
          context.showSnackBar(error.message, isError: true);
        }
      } catch (error) {
        if (mounted) {
          context.showSnackBar('Ocorreu um erro inesperado, tente novamente mais tarde', isError: true);
        }
      }

      setState(() => _isLoading = false);
    }
  }
}
