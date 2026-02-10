import 'package:flutter/material.dart';

class PaymentTypeSelector extends StatelessWidget {
  final String selectedType; // 'CREDIT', 'DEBIT' ou 'PIX'
  final Function(String) onTypeChanged;
  final bool isLoading;

  const PaymentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CRÉDITO
        _buildButton("CRÉDITO", "CREDIT"),
        const SizedBox(width: 8),

        // DÉBITO
        _buildButton("DÉBITO", "DEBIT"),
        const SizedBox(width: 8),

        // PIX (O Novo!) 💠
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // Se for PIX, usa Verde para destacar, se não cinza
                backgroundColor: selectedType == 'PIX'
                    ? const Color(0xFF32BCAD) // Um verde "estilo Pix"
                    : Colors.grey[200],
                foregroundColor: selectedType == 'PIX'
                    ? Colors.white
                    : Colors.black54,
                elevation: selectedType == 'PIX' ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero, // Para caber o texto
              ),
              onPressed: isLoading ? null : () => onTypeChanged("PIX"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code, size: 18), // Ícone do Pix
                  SizedBox(width: 4),
                  Text("PIX", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, String value) {
    final isSelected = selectedType == value;
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF0056D2)
                : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black54,
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isLoading ? null : () => onTypeChanged(value),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ), // Fonte menor pra caber
        ),
      ),
    );
  }
}
