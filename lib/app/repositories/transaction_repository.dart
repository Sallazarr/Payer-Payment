import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:payer_payment/app/core/constants.dart';
import '../models/transaction_payload.dart';

class TransactionRepository {
  final Dio _dio = Dio();

  // PEGA TOKEN DE AUTENTICAÇÃO

  Future<String> _getAuthToken() async {
    try {
      debugPrint("[AUTH] Conectando em: ${PayerConfig.tokenUrl}");
      final Map<String, dynamic> loginBody = {
        "clientId": PayerConfig.clientId,
        "username": PayerConfig.username,
        "password": PayerConfig.password,
      };

      final response = await _dio.post(
        PayerConfig.tokenUrl,
        data: loginBody,
        options: Options(headers: {'Contet-Type': 'application/json'}),
      );
      final data = response.data;
      final String idToken = data['AuthenticationResult']['IdToken'];

      debugPrint("[AUTH] Token obtido com sucesso!");
      return idToken;
    } on DioException catch (e) {
      if (e.response == null) {
        debugPrint("[AUTH] Erro de Conexão!");
        debugPrint("Motivo: ${e.message}");
        debugPrint("Tipo do erro: ${e.type}");
        throw Exception("Sem conexão com a internet");
      }
      // ERRO DA API
      else {
        debugPrint("[AUTH] API Recusou:");
        debugPrint("Status: ${e.response?.statusCode}");
        debugPrint("Dados: ${e.response?.data}");
        throw Exception("Erro na API: ${e.response?.statusCode}");
      }
    }
  }

  //CRIA TRANSAÇÃO
  Future<void> sendTransaction(TransactionPayload payload) async {
    try {
      final String token = await _getAuthToken();
      debugPrint("[API] Enviando para: ${PayerConfig.transactionUrl}");

      final response = await _dio.post(
        PayerConfig.transactionUrl,
        data: payload.toJson(),
        options: Options(
          headers: {
            'Contet-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      debugPrint("[API] Sucesso! Status: ${response.statusCode}");
      debugPrint("[API] Resposta da Payer: ${response.data}");
    } on DioException catch (e) {
      debugPrint("[API] ERRO NA VENDA:");
      if (e.response != null) {
        debugPrint("Status: ${e.response?.statusCode}");
        debugPrint("ERRO: ${e.response?.data}");
      } else {
        debugPrint("ERRO DE CONEXÃO: ${e.message}");
      }
      throw Exception("ERRO AO ENVIAR TRANSAÇÃO");
    }
    final jsonString = jsonEncode(payload.toJson());

    debugPrint("------------------------------------------------");
    debugPrint("JSON GERADO COM SUCESSO:");
    debugPrint(jsonString);
    debugPrint("------------------------------------------------");
  }

  // POLLING
  Future<Map<String, dynamic>?> checkPaymentStatus(
    String meuCorrelationId,
  ) async {
    try {
      final response = await _dio.get(
        PayerConfig.pollingUrl,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final List<dynamic> requests = response.data['data'];

      if (requests.isEmpty) return null;

      // PROCURA NA LISTA
      for (var request in requests) {
        final String contentString = request['content'];

        // verificar se é um JSON válido antes de tentar ler
        if (contentString.isEmpty) continue;

        try {
          final Map<String, dynamic> payerData = jsonDecode(contentString);

          // Só retorna se o ID da mensagem for igual ao ID que nós enviamos
          if (payerData['correlationId'] == meuCorrelationId) {
            debugPrint("📥 JSON DO POLLING (RESPOSTA): $payerData");

            return payerData;
          }
        } catch (e) {
          // Se o JSON estiver quebrado, ignora e vai para o próximo
          continue;
        }
      }

      // Se varreu tudo e não achou o nosso ID
      return null;
    } catch (e) {
      debugPrint("⚠️ Erro no Polling: $e");
      return null;
    }
  }
}
