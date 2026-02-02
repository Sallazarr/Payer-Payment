import 'package:payer_payment/app/core/constants.dart';
import 'package:uuid/uuid.dart';

class TransactionPayload {
  final double value;
  final String paymentMethod;
  final String paymentType;
  final String paymentMethodSubType;
  final int installments;

  TransactionPayload({
    required this.value,
    required this.paymentMethod,
    required this.paymentType,
    required this.installments,
    required this.paymentMethodSubType,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": "INPUT",
      "origin": "PAGAMENTO",
      "data": {
        "callbackUrl": PayerConfig.callbackUrl,
        "correlationId": const Uuid().v4(),
        "flow": "SYNC",
        "automationName": PayerConfig.automationName, // fornecido no onboarding
        "receiver": {
          "companyId": PayerConfig.companyId, // fornecido no onboarding
          "storeId": PayerConfig.storeId, // fornecido no onboarding
          "terminalId": PayerConfig.terminalId,
        },
        "message": {
          "command": "PAYMENT",
          "paymentMethod": paymentMethod,
          "paymentType": paymentType,
          "paymentMethodSubType": paymentMethodSubType,
          "installments": installments,
          "value": value,
        },
      },
    };
  }
}
