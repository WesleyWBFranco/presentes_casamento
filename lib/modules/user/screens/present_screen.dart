import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/common/widgets/standard_screen.dart';
import 'package:presentes_casamento/data/models/present.dart';
import 'package:presentes_casamento/modules/user/widgets/present_card.dart';
import 'package:provider/provider.dart';
import 'package:presentes_casamento/services/cart_services.dart';

class PresentScreen extends StatefulWidget {
  const PresentScreen({super.key});

  @override
  State<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends State<PresentScreen> {
  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('presents').get();
    final uniqueCategories =
        snapshot.docs
            .map((doc) => doc['category']?.toString() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();

    setState(() {
      categories = ['Todos', ...uniqueCategories];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartItemCount = cartService.items.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou preço',
                hintStyle: GoogleFonts.libreBaskerville(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 196, 196, 196),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.libreBaskerville(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory = selected ? category : 'Todos';
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('presents')
                      .orderBy('price')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhum presente encontrado'),
                  );
                }

                final docs = snapshot.data!.docs;

                final presents =
                    docs
                        .map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Present(
                            name: data['name'] ?? '',
                            price: (data['price'] ?? 0).toDouble(),
                            imagePath: data['imagePath'] ?? '',
                            quantity: data['quantity'] ?? 0,
                            category: data['category'] ?? '',
                          );
                        })
                        .where(
                          (present) =>
                              (selectedCategory == 'Todos' ||
                                  present.category == selectedCategory) &&
                              (present.name.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  present.price
                                      .toString()
                                      .toLowerCase()
                                      .contains(_searchQuery)),
                        )
                        .toList();

                return GridView.builder(
                  itemCount: presents.length,
                  // ALTERADO: Usando SliverGridDelegateWithMaxCrossAxisExtent para melhor responsividade
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280.0, // Largura máxima para cada item
                    childAspectRatio: 0.64, // Mantendo o aspect ratio original
                    crossAxisSpacing:
                        8.0, // Espaçamento horizontal entre os cards
                    mainAxisSpacing: 8.0, // Espaçamento vertical entre os cards
                  ),
                  itemBuilder: (context, index) {
                    final present = presents[index];
                    final doc = getDocForPresent(present, docs);

                    if (doc == null) return const SizedBox.shrink();

                    return PresentCard(present: present, documentId: doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          cartItemCount > 0
              ? FloatingActionButton(
                onPressed: () {
                  final standardScreenState =
                      context.findAncestorStateOfType<StandardScreenState>();
                  if (standardScreenState != null) {
                    standardScreenState.changePage(2, fromDrawer: false);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StandardScreen(),
                      ),
                    );
                  }
                },
                backgroundColor: Colors.black,
                child: Image.asset(
                  'assets/images/carrinho2.png',
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

QueryDocumentSnapshot? getDocForPresent(
  Present present,
  List<QueryDocumentSnapshot> docs,
) {
  try {
    return docs.firstWhere((d) => d['name'] == present.name);
  } catch (e) {
    return null;
  }
}
