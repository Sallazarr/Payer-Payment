import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:payer_payment/app/models/transaction_payload.dart';
import 'package:payer_payment/app/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:payer_payment/app/database/database_helper.dart';

enum HomeState { idle, loading, success, error }

class HomeController {
  final _repository = TransactionRepository();
  final state = ValueNotifier<HomeState>(HomeState.idle);
  final valueController = TextEditingController();

  String paymentType = 'CREDIT';
  int installments = 1;
  String? currentErrorMessage;

  Future<void> startTransaction() async {
    if (valueController.text.isEmpty) {
      currentErrorMessage = "Digite um valor válido.";
      state.value = HomeState.error;
      return;
    }

    currentErrorMessage = null;
    state.value = HomeState.loading;

    try {
      final double amount = UtilBrasilFields.converterMoedaParaDouble(
        valueController.text,
      );
      final String correlationId = const Uuid().v4();

      // Configuração do Payload
      String finalPaymentMethod;
      String finalPaymentType;
      String finalSubType;

      if (paymentType == 'PIX') {
        finalPaymentMethod = "PIX";
        finalPaymentType = "DEBIT";
        finalSubType = "FULL_PAYMENT";
      } else {
        finalPaymentMethod = "CARD";
        finalPaymentType = paymentType;
        finalSubType = installments > 1 ? "FINANCED_NO_FEES" : "FULL_PAYMENT";
      }

      final payload = TransactionPayload(
        value: amount,
        paymentMethod: finalPaymentMethod,
        paymentType: finalPaymentType,
        installments: (paymentType == 'PIX' || paymentType == 'DEBIT')
            ? 1
            : installments,
        paymentMethodSubType: finalSubType,
        customCorrelationId: correlationId,
      );

      await _repository.sendTransaction(payload);

      debugPrint("⏳ Transação enviada! Aguardando...");

      bool paid = false;

      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final response = await _repository.checkPaymentStatus(correlationId);

        if (response != null) {
          final status = response['statusTransaction'];
          final idTransacao = response['idPayer']; // ID que vem da Payer

          debugPrint("📩 Status: $status | ID: $idTransacao");

          // --- CASO 1: APROVADO ✅ ---
          if (status == "APPROVED") {
            paid = true;
            final comprovante = response['shopTextReceipt'];

            // Salva como Aprovado
            _saveToDatabase(
              id: idTransacao,
              amount: amount,
              status: status,
              info: comprovante ?? "Sem comprovante",
            );

            break;
          } else if (status == "DENIED" ||
              status == "CANCELED" ||
              status == "ABORTED" ||
              status == "REJECTED") {
            String? apiMessage;

            if (response['rejectionInfo'] != null) {
              apiMessage = response['rejectionInfo']['rejectionMessage'];
            }

            if (apiMessage != null && apiMessage.isNotEmpty) {
              currentErrorMessage = apiMessage;
            } else {
              // Se a API não mandar nada, usamos textos de fallback
              if (status == "ABORTED") {
                currentErrorMessage = "⚠️ Operação abortada na maquininha.";
              } else if (status == "DENIED") {
                currentErrorMessage = "⛔ Transação Negada pelo banco.";
              } else {
                currentErrorMessage = "❌ Operação Cancelada.";
              }
            }

            // SALVA NO BANCO O MOTIVO EXATO
            _saveToDatabase(
              id: idTransacao,
              amount: amount,
              status: status,
              info: currentErrorMessage!,
            );

            break;
          }
        }
      }

      if (paid) {
        state.value = HomeState.success;
        _resetForm();
      } else {
        currentErrorMessage ??= "⏰ Tempo excedido.";
        state.value = HomeState.error;
      }
    } catch (e) {
      currentErrorMessage = "Erro de conexão: $e";
      state.value = HomeState.error;
    }
  }

  // --- FUNÇÃO AUXILIAR PARA SALVAR (Evita repetir código) ---
  Future<void> _saveToDatabase({
    required String? id,
    required double amount,
    required String status,
    required String info,
  }) async {
    try {
      await DatabaseHelper().insertTransaction({
        'transactionId': id ?? 'PENDENTE',
        'value': amount,
        'status': status,
        'date': DateTime.now().toString(),
        'receiptText': info, // Se aprovado é o Recibo, se erro é o Motivo
      });
      debugPrint("💾 Histórico salvo: $status");
    } catch (e) {
      debugPrint("⚠️ Erro ao salvar banco: $e");
    }
  }

  void _resetForm() {
    valueController.clear();
    installments = 1;
    paymentType = 'CREDIT';
  }
}
