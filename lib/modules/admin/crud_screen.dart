import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presentes_casamento/data/models/present.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imagePathController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  String _searchQuery = '';
  String selectedCategory = 'Todas';
  List<String> categories = ['Todas'];
  List<String> _existingCategories = [];
  String? _selectedExistingCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadExistingCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('presents').get();
    final uniqueCategories =
        snapshot.docs
            .map((doc) => doc['category']?.toString() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();

    setState(() {
      categories = ['Todas', ...uniqueCategories];
    });
  }

  Future<void> _loadExistingCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('presents').get();
    final uniqueCategories =
        snapshot.docs
            .map((doc) => doc['category']?.toString() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    setState(() {
      _existingCategories = uniqueCategories;
    });
  }

  void openPresentBox({
    String? docID,
    Map<String, dynamic>? existingData,
  }) async {
    _selectedExistingCategory = null;
    if (existingData != null) {
      nameController.text = existingData['name'] ?? '';
      priceController.text = (existingData['price'] ?? '').toString();
      imagePathController.text = existingData['imagePath'] ?? '';
      quantityController.text = (existingData['quantity'] ?? '').toString();
      categoryController.text = existingData['category'] ?? '';
      _selectedExistingCategory = existingData['category'];
    } else {
      nameController.clear();
      priceController.clear();
      imagePathController.clear();
      quantityController.clear();
      categoryController.clear();
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              docID == null ? "Adicionar Presente" : "Editar Presente",
              style: GoogleFonts.libreBaskerville(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: "Preço",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: imagePathController,
                    decoration: const InputDecoration(
                      labelText: "Caminho da Imagem",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantidade",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Selecionar Categoria",
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    value: _selectedExistingCategory,
                    items:
                        _existingCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedExistingCategory = newValue;
                        if (newValue != null) {
                          categoryController.text = newValue;
                        }
                      });
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: "Ou digite uma Nova Categoria",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                // Adicionado Row para alinhar os botões lado a lado
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround, // Distribui o espaço entre os botões
                children: [
                  Expanded(
                    // Faz o botão "Cancelar" ocupar o espaço disponível
                    child: TextButton(
                      style: ButtonStyle(
                        side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.black, width: 2),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                            vertical: 8,
                          ), // Reduz o padding vertical
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10), // Espaçamento entre os botões
                  Expanded(
                    // Faz o botão "Salvar" ocupar o espaço disponível
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ), // Reduz o padding vertical
                      ),
                      onPressed: () async {
                        // REVERTIDO: Cria o objeto Present diretamente dos controllers
                        final present = Present(
                          name: nameController.text,
                          price: double.tryParse(priceController.text) ?? 0.0,
                          imagePath: imagePathController.text,
                          quantity: int.tryParse(quantityController.text) ?? 0,
                          category: categoryController.text.trim(),
                        );

                        if (docID == null) {
                          await firestoreService.addPresent(
                            present,
                          ); // Passa o objeto Present
                        } else {
                          await firestoreService.updatePresent(
                            docID,
                            present,
                          ); // Passa o objeto Present
                        }

                        Navigator.pop(context);
                      },
                      child: Text(
                        "Salvar",
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => openPresentBox(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
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
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Selecionar Categoria',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              dropdownColor: Colors.white,
              value: selectedCategory,
              items: [
                ...categories.map(
                  (categories) => DropdownMenuItem<String>(
                    value: categories,
                    child: Text(
                      categories.isNotEmpty ? categories : categories,
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getPresentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final docs =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final present = Present(
                            name: data['name'] ?? '',
                            price: (data['price'] as num?)?.toDouble() ?? 0.0,
                            imagePath: data['imagePath'] ?? '',
                            quantity: (data['quantity'] as num?)?.toInt() ?? 0,
                            category: data['category']?.toString() ?? '',
                          );
                          final category = data['category']?.toString() ?? '';

                          final nameMatches = present.name
                              .toLowerCase()
                              .contains(_searchQuery);
                          final priceMatches = present.price
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery);
                          return (selectedCategory == 'Todas' ||
                                  category == selectedCategory) &&
                              (nameMatches || priceMatches);
                        }).toList();

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2.0),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.network(
                                  data['imagePath'] ?? '',
                                  fit: BoxFit.scaleDown,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(
                              data['name'] ?? 'Sem nome',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.libreBaskerville(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              'R\$ ${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                              style: GoogleFonts.rajdhani(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed:
                                      () => openPresentBox(
                                        docID: doc.id,
                                        existingData: data,
                                      ),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      () => firestoreService.deletePresent(
                                        doc.id,
                                      ),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
