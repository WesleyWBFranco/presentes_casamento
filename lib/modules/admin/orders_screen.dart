import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _selectedUserName;
  List<String> _userNames = [];
  List<Map<String, dynamic>> _userOrders = [];
  bool _isLoadingUsers = true;
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    setState(() {
      _isLoadingUsers = true;
      _userNames.clear();
      _selectedUserName = null;
      _userOrders.clear();
    });
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('compras')
              .orderBy('userName')
              .get();
      final uniqueNames =
          snapshot.docs
              .map((doc) => doc['userName'] as String?)
              .toSet()
              .toList();
      uniqueNames.removeWhere((name) => name == null);
      setState(() {
        _userNames = uniqueNames.cast<String>().toList();
        _isLoadingUsers = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar usuários: $error')),
      );
    }
  }

  Future<void> _loadOrdersForUser(String userName) async {
    setState(() {
      _isLoadingOrders = true;
      _userOrders.clear();
    });
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('compras')
              .where('userName', isEqualTo: userName)
              .orderBy('timestamp', descending: true)
              .get();
      final ordersData = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _userOrders = ordersData.cast<Map<String, dynamic>>();
        _isLoadingOrders = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingOrders = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pedidos: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text(
            'Pedidos de Usuários',
            style: GoogleFonts.libreBaskerville(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                _isLoadingUsers
                    ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                    : _userNames.isEmpty
                    ? Text(
                      'Nenhum usuário fez compras ainda.',
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Selecionar Usuário',
                        labelStyle: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _selectedUserName,
                      items:
                          _userNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUserName = newValue;
                          if (newValue != null) {
                            _loadOrdersForUser(newValue);
                          } else {
                            _userOrders.clear();
                          }
                        });
                      },
                    ),
          ),
          Expanded(
            child:
                _isLoadingOrders
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                    : _userOrders.isEmpty && _selectedUserName != null
                    ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum pedido encontrado para este usuário.',
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: _userOrders.length,
                      itemBuilder: (context, index) {
                        final order = _userOrders[index];
                        final items = (order['items'] as List<dynamic>?) ?? [];
                        final total = order['total'] as double?;
                        final timestamp = order['timestamp'] as Timestamp?;
                        final formattedDate =
                            timestamp != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                  timestamp.millisecondsSinceEpoch,
                                ).toLocal().toString()
                                : 'Data não disponível';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedido em: $formattedDate',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const Divider(),
                                for (var item in items)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['name'] as String? ??
                                                'Nome Indisponível',
                                            style: GoogleFonts.libreBaskerville(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'x${item['quantity']}',
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'R\$ ${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total: R\$ ${total?.toStringAsFixed(2) ?? '0.00'}',
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
