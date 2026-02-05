import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../controllers/home_controller.dart'; // Importe seu controller

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instanciamos o Controller
  final controller = HomeController();

  @override
  void initState() {
    super.initState();
    // Escuta mudanças de estado (Sucesso/Erro) para mostrar avisos
    controller.state.addListener(() {
      final state = controller.state.value;
      if (state == HomeState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transação Enviada com Sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state == HomeState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Erro ao enviar. Verifique o valor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payer Payment')),
      // ValueListenableBuilder reconstrói a tela quando o estado muda (ex: Loading)
      body: ValueListenableBuilder<HomeState>(
        valueListenable: controller.state,
        builder: (context, state, child) {
          final isLoading = state == HomeState.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.point_of_sale,
                  size: 80,
                  color: Color(0xFF0056D2),
                ),
                const SizedBox(height: 30),

                // Campo de Valor
                TextFormField(
                  controller: controller.valueController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: 'R\$ 0,00',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CentavosInputFormatter(moeda: true),
                  ],
                ),
                const SizedBox(height: 24),

                // Botões de Tipo (Crédito/Débito)
                Row(
                  children: [
                    // Botão Crédito
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // Se estiver selecionado, fica Azul. Se não, Cinza.
                          backgroundColor: controller.paymentType == 'CREDIT'
                              ? const Color(0xFF0056D2)
                              : Colors.grey[300],
                          foregroundColor: controller.paymentType == 'CREDIT'
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(
                                  () => controller.paymentType = 'CREDIT',
                                );
                              },
                        child: const Text('CRÉDITO'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Botão Débito
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.paymentType == 'DEBIT'
                              ? const Color(0xFF0056D2)
                              : Colors.grey[300],
                          foregroundColor: controller.paymentType == 'DEBIT'
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  controller.paymentType = 'DEBIT';
                                  controller.installments =
                                      1; // Reseta parcelas visualmente
                                });
                              },
                        child: const Text('DÉBITO'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Slider de Parcelas (Só aparece se for Crédito)
                if (controller.paymentType == 'CREDIT') ...[
                  Text(
                    "Parcelas: ${controller.installments}x",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: controller.installments.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    onChanged: isLoading
                        ? null
                        : (val) {
                            setState(
                              () => controller.installments = val.toInt(),
                            );
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
                            // Esconde o teclado
                            FocusScope.of(context).unfocus();
                            // Chama o Controller
                            controller.startTransaction();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
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
      ),
    );
  }
}
