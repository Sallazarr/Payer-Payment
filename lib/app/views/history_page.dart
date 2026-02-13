import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payer_payment/app/core/app_colors.dart';
import '../database/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var data = await DatabaseHelper().getTransactions();
    // Inverte a lista: o mais recente (topo) é o último que entrou
    data = data.reversed.toList();

    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  String _formatMoney(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Histórico de Vendas",
          style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            )
          : _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhuma venda registrada.",
                    style: TextStyle(fontSize: 18, color: AppColors.gray),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final item = _transactions[index];

                final status = item['status'];
                final valor = item['value'];
                final data = item['date'];
                final recibo = item['receiptText'];

                final bool isApproved = status == "APPROVED";

                // --- CORES FORTES E SÓLIDAS ---
                // Verde Sucesso vs Vermelho Vivo (Padrão Material)
                final Color solidColor = isApproved
                    ? const Color(0xFF2E7D32) // Verde Forte (Green 800)
                    : Colors.red; // Vermelho Vivo Padrão

                final IconData solidIcon = isApproved
                    ? Icons.check
                    : Icons.close;
                final String statusText = isApproved ? "Aprovada" : "Recusada";

                return Card(
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!), // Borda sutil
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      // ÍCONE SÓLIDO (Bolinha Colorida)
                      leading: CircleAvatar(
                        backgroundColor: solidColor, // Cor Fundo Sólida
                        radius: 24,
                        child: Icon(
                          solidIcon,
                          color: Colors.white, // Ícone Branco
                          size: 26,
                        ),
                      ),

                      title: Text(
                        _formatMoney(valor),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.gray,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Texto colorido indicando status
                          Text(
                            statusText.toUpperCase(),
                            style: TextStyle(
                              color: solidColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(data),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showReceiptDialog(recibo, isApproved, solidColor);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showReceiptDialog(String receipt, bool isApproved, Color colorHeader) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Título colorido combinando com o status
        title: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.error,
              color: colorHeader,
            ),
            const SizedBox(width: 10),
            Text(
              isApproved ? "Comprovante" : "Erro",
              style: TextStyle(color: colorHeader),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              receipt,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Fechar",
              style: TextStyle(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
