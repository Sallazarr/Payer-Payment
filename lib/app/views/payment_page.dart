import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:payer_payment/app/core/app_colors.dart';
import 'package:payer_payment/app/core/app_images.dart';
import '../controllers/home_controller.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.state.addListener(() {
      final state = controller.state.value;

      if (state == HomeState.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transação Enviada com Sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (state == HomeState.error) {
        if (!mounted) return;
        final msg = controller.currentErrorMessage ?? "Erro desconhecido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  // Helper de Botões
  Widget _buildPaymentButton({
    required String label,
    required String value,
    required IconData icon,
    Color activeColor = AppColors.orange,
  }) {
    final isSelected = controller.paymentType == value;
    final isLoading = controller.state.value == HomeState.loading;

    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            backgroundColor: isSelected ? activeColor : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black54,
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    controller.paymentType = value;
                    if (value == 'PIX' || value == 'DEBIT') {
                      controller.installments = 1;
                    }
                  });
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeState>(
      valueListenable: controller.state,
      builder: (context, state, child) {
        final isLoading = state == HomeState.loading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // LOGO PAYER
              SizedBox(height: 60, child: SvgPicture.asset(AppImages.logo)),

              const SizedBox(height: 40),

              // Campo de Valor
              TextFormField(
                controller: controller.valueController,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  labelStyle: TextStyle(color: AppColors.grey),
                  hintText: 'R\$ 0,00',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.orange, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CentavosInputFormatter(moeda: true),
                ],
              ),
              const SizedBox(height: 24),

              // Seletor de Pagamento
              Row(
                children: [
                  _buildPaymentButton(
                    label: "CRÉDITO",
                    value: "CREDIT",
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentButton(
                    label: "DÉBITO",
                    value: "DEBIT",
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentButton(
                    label: "PIX",
                    value: "PIX",
                    icon: Icons.qr_code_2,
                    activeColor: AppColors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Slider de Parcelas
              if (controller.paymentType == 'CREDIT') ...[
                Text(
                  "Parcelas: ${controller.installments}x",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
                Slider(
                  value: controller.installments.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  activeColor: AppColors.orange,
                  thumbColor: AppColors.orange,
                  onChanged: isLoading
                      ? null
                      : (val) {
                          setState(() => controller.installments = val.toInt());
                        },
                ),
              ],

              const SizedBox(height: 32),

              // Botão de Enviar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          controller.startTransaction();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("COBRAR", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
