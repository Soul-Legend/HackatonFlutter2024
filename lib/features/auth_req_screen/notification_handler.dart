import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


// Exceção customizada para erros de notificação
class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}

// Classe NotificationHandler
class NotificationHandler {
  // Construtor privado para evitar instanciamento
  NotificationHandler._();

  // Função para enviar a notificação usando NotificationAPI
  static Future<bool> sendNotification({
    required String userId,
    required String? userEmail,
    required String notificationId,
  }) async {
    try {
      // URL da API NotificationAPI
      const String apiUrl =
          'https://api.notificationapi.com/17ie6bjmik4btlxeluerv1xfp3/sender';

      // Cabeçalhos da requisição
      final Map<String, String> headers = {
        'Authorization': dotenv.env['NOTIFICATION_AUTHORIZATION_KEY']!, // A chave está definida aqui
        'Content-Type': 'application/json',
      };

      // Corpo da requisição (dados JSON)
      final Map<String, dynamic> body = {
        "notificationId": notificationId,
        "user": {
          "id": userId, // ID do usuário (e-mail ou outro identificador único)
          "email": userEmail, // E-mail do usuário
          "number": "000000000000", // Número de telefone do usuário
        },
        "mergeTags":
            {}, // Tag de mesclagem (se necessário, pode ser deixado vazio)
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body), // Envia o corpo como JSON
      );

      // Verifica a resposta
      if (response.statusCode == 200) {
        return true;
      } else {
        throw NotificationException('Não foi possível enviar a declaração!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
