import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
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
    } catch (e) {}
  }
}
