import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:payer_payment/app/models/transaction_payload.dart';
import 'package:payer_payment/app/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

enum HomeState { idle, loading, success, error }

class HomeController {
  final _repository = TransactionRepository();

  final state = ValueNotifier<HomeState>(HomeState.idle);

  final valueController = TextEditingController();
  String paymentType = 'CREDIT';
  int installments = 1;

  Future<void> startTransaction() async {
    if (valueController.text.isEmpty) {
      state.value = HomeState.error;
      return;
    }
    state.value = HomeState.loading;

    try {
      // 1. Prepara e Envia
      final double amount = UtilBrasilFields.converterMoedaParaDouble(
        valueController.text,
      );
      String subType = installments > 1 ? "FINANCED_NO_FEES" : "FULL_PAYMENT";

      final String correlationId = const Uuid().v4();

      final payload = TransactionPayload(
        value: amount,
        paymentMethod: "CARD",
        paymentType: paymentType,
        installments: paymentType == "DEBIT" ? 1 : installments,
        paymentMethodSubType: subType,
        customCorrelationId: correlationId,
      );

      await _repository.sendTransaction(payload);

      // 2. Loop de Polling Inteligente 🧠
      debugPrint("⏳ Transação enviada! Aguardando o Simulador responder...");

      bool paid = false;
      String? comprovante; // Vamos guardar o texto do recibo aqui

      for (int i = 0; i < 15; i++) {
        // Aumentei para 15x (45seg) por segurança
        await Future.delayed(const Duration(seconds: 3));

        final response = await _repository.checkPaymentStatus(correlationId);

        if (response != null) {
          // Agora usamos os nomes EXATOS dos campos do seu JSON
          final status = response['statusTransaction']; // Deve ser "APPROVED"
          final idTransacao = response['idPayer'];

          debugPrint("📩 Status recebido: $status | ID: $idTransacao");

          if (status == "APPROVED") {
            paid = true;
            // Pega o comprovante bonitinho que o simulador mandou
            comprovante = response['shopTextReceipt'];

            // Exibe o comprovante no console (ou futuramente imprime)
            debugPrint("🧾 COMPROVANTE RECEBIDO:\n$comprovante");
            break;
          } else if (status == "DENIED" || status == "CANCELED") {
            // Se o simulador negar, a gente para de tentar
            debugPrint("❌ Transação Negada pelo Simulador.");
            break;
          }
        }
      }

      if (paid) {
        state.value = HomeState.success;
        _resetForm();
        // Dica: Aqui você poderia abrir um Dialog mostrando o 'comprovante' na tela!
      } else {
        debugPrint("⏰ O Simulador demorou demais ou não respondeu.");
        state.value = HomeState.error;
      }
    } catch (e) {
      debugPrint("❌ Erro no fluxo: $e");
      state.value = HomeState.error;
    }
  }

  void _resetForm() {
    valueController.clear();
    installments = 1;
    paymentType = 'CREDIT';
  }
}
