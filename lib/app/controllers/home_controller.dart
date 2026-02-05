import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:payer_payment/app/models/transaction_payload.dart';
import 'package:payer_payment/app/repositories/transaction_repository.dart';

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
      final double amount = UtilBrasilFields.converterMoedaParaDouble(
        valueController.text,
      );
      String subType = installments > 1 ? "FINANCED_NO_FEES" : "FULL_PAYMENT";

      final payload = TransactionPayload(
        value: amount,
        paymentMethod: "CARD",
        paymentType: paymentType,
        installments: paymentType == "DEBIT" ? 1 : installments,
        paymentMethodSubType: subType,
      );

      await _repository.sendTransaction(payload);

      state.value = HomeState.success;

      _resetForm();
    } catch (e) {
      state.value = HomeState.error;
    }
  }

  void _resetForm() {
    valueController.clear();
    installments = 1;
    paymentType = 'CREDIT';
  }
}
