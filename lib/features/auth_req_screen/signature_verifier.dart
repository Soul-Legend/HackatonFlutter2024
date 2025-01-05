import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Exceção customizada para erros de notificação
class SignatureVerifierException implements Exception {
  final String message;

  SignatureVerifierException(this.message);

  @override
  String toString() => 'SignatureVerifierException: $message';
}

// Classe SignatureVerifier
class SignatureVerifier {
  // Construtor privado para evitar instanciamento
  SignatureVerifier._();

  // Função para enviar a notificação usando NotificationAPI
  static Future<int> verifySignature({
    required String signedFile,
    required String fullName,
    required String cpf,
  }) async {
    final uri = Uri.parse('https://pbad.labsec.ufsc.br/verifier-hom/report');
    final request = http.MultipartRequest('POST', uri)
      ..fields['report_type'] = 'json'
      ..fields['emit_receipt'] = 'false'
      ..fields['extended_report'] = 'true'
      ..fields['show_payload_json'] = 'true'
      ..fields['verify_incremental_updates'] = 'false'
      ..files.add(
        await http.MultipartFile.fromPath(
          'signature_files[]',
          signedFile,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    final String sigSubjectName;
    final String sigCpf;
    final bool sigIsValid;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final List<int> bytes = await response.stream.toBytes();
        final String jsonString = utf8.decode(bytes);

        // Decodificar o JSON
        final Map<String, dynamic> responseBody =
            jsonDecode(jsonString) as Map<String, dynamic>;
        // ignore: avoid_dynamic_calls
        sigSubjectName = (responseBody["reports"][0]["signatures"]["signature"]
                ["certification"]["signer"]["subjectName"] as String)
            .substring(3);
        // ignore: avoid_dynamic_calls
        sigCpf = (responseBody["reports"][0]["signatures"]["signature"]
                    ["certification"]["signer"]["extensions"]["generalName"]
                ["subjectAlternativeNames"]["value"] as String)
            .replaceAll("*", "")
            .replaceAll(".", "")
            .replaceAll("-", "");
        // ignore: avoid_dynamic_calls
        sigIsValid = (responseBody["reports"][0]["generalStatus"] as String) ==
            "Aprovado";
      } else {
        throw SignatureVerifierException(
          'Não foi possível verificar a declaração!',
        );
      }
    } catch (e) {
      rethrow;
    }

    // Apenas os 6 digitos do meio do cpf
    final String cpf3To9 = cpf
        .replaceAll("*", "")
        .replaceAll(".", "")
        .replaceAll("-", "")
        .substring(3, 9);

    if (sigIsValid) {
      if (sigSubjectName == fullName.toUpperCase() && sigCpf == cpf3To9) {
        return 0; // Assinatura válida e usuário logado tem as mesmas informações da assinatura
      } else {
        return 1; // Assinatura válida e usuário logado não tem as mesmas informações da assinatura
      }
    } else {
      return 2; // Assinatura inválida
    }
  }
}
