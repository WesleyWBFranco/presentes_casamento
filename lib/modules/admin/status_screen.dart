import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  int totalItens = 0;
  int itensPresentes = 0;
  double valorTotal = 0.0;
  double valorPresenteado = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatusData();
  }

  Future<void> _loadStatusData() async {
    setState(() {
      isLoading = true;
    });

    final itemsSnapshot =
        await FirebaseFirestore.instance.collection('presents').get();

    final comprasSnapshot =
        await FirebaseFirestore.instance.collection('compras').get();

    int tempTotalItens = 0;
    double tempValorTotal = 0.0;

    for (var doc in itemsSnapshot.docs) {
      final data = doc.data();
      final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      tempTotalItens += quantity;
      tempValorTotal += quantity * price;
    }

    int tempItensPresentes = 0;
    double tempValorPresenteado = 0.0;

    for (var doc in comprasSnapshot.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        // Acesse a quantidade e o preço do mapa 'item', NÃO de 'data'
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        tempItensPresentes += quantity;
        tempValorPresenteado += quantity * price;
      }
    }

    setState(() {
      totalItens = tempTotalItens + tempItensPresentes;
      itensPresentes = tempItensPresentes;
      valorTotal = tempValorTotal + tempValorPresenteado;
      valorPresenteado = tempValorPresenteado;
      isLoading = false;
    });
  }

  Widget _buildProgressCard(String title, int current, int total) {
    final percent = total > 0 ? current / total : 0.0;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.libreBaskerville(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              color: Colors.black,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '$current de $total',
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(String title, double current, double total) {
    final percent = total > 0 ? current / total : 0.0;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.libreBaskerville(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              color: Colors.black,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              'R\$ ${current.toStringAsFixed(2)} de R\$ ${total.toStringAsFixed(2)}',
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Progresso dos Presentes',
            style: GoogleFonts.libreBaskerville(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
              : Column(
                children: [
                  _buildProgressCard(
                    'Itens Presentes',
                    itensPresentes,
                    totalItens,
                  ),
                  _buildValueCard(
                    'Valor Presenteado',
                    valorPresenteado,
                    valorTotal,
                  ),
                ],
              ),
    );
  }
}
