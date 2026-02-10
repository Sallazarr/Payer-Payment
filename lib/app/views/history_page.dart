import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar dinheiro e data
import '../database/database_helper.dart'; // Importe seu banco

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Lista para guardar as vendas que vêm do banco
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Busca os dados no SQLite
  Future<void> _loadData() async {
    final data = await DatabaseHelper().getTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  // Formata valor (R$ 10,00)
  String _formatMoney(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  // Formata data (10/02/2026 14:30)
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Vendas"),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma venda registrada.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final item = _transactions[index];

                // Extraindo dados do Map do SQLite
                final status = item['status'];
                final valor = item['value'];
                final data = item['date'];
                final recibo = item['receiptText'];
                final id = item['transactionId'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: status == "APPROVED"
                          ? Colors.green
                          : Colors.red,
                      child: Icon(
                        status == "APPROVED" ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      _formatMoney(valor),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(data)),
                        Text("ID: $id", style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Mostra o comprovante ao clicar
                      _showReceiptDialog(recibo);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showReceiptDialog(String receipt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Comprovante"),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            width: double.maxFinite,
            child: Text(
              receipt,
              style: const TextStyle(
                fontFamily: 'Courier', // Fonte monoespaçada igual cupom fiscal
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }
}
