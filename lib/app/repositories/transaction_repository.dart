import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/transaction_payload.dart';

class TransactionRepository {
  // Função que envia a transação
  Future<void> sendTransaction(TransactionPayload payload) async {
    // Simula a internet pensando por 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    final jsonString = jsonEncode(payload.toJson());

    debugPrint("------------------------------------------------");
    debugPrint("🚀 JSON GERADO COM SUCESSO:");
    debugPrint(jsonString);
    debugPrint("------------------------------------------------");
  }
}
