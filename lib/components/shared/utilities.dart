import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String generateHash(String input) {
  final String saltedInput =
      "${input}saaaaaaaaaaaaaaaalt"; // Adiciona o sal à entrada
  final Uint8List bytes =
      utf8.encode(saltedInput); // converte a string para uma lista de bytes
  final Digest digest = sha256.convert(bytes); // gera o hash SHA-256
  return digest.toString(); // retorna o hash como uma string hexadecimal
}
