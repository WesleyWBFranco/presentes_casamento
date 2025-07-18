import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/common/widgets/standard_screen.dart';
import 'package:presentes_casamento/data/models/present.dart';
import 'package:presentes_casamento/modules/user/widgets/present_card.dart';
import 'package:provider/provider.dart';
import 'package:presentes_casamento/services/cart_services.dart';
import 'package:flutter/services.dart'; // Importe para usar Clipboard

class PresentScreen extends StatefulWidget {
  // Adicionado um novo parâmetro para controlar a exibição do popup
  final bool shouldShowPixPopup;

  const PresentScreen({
    super.key,
    this.shouldShowPixPopup = false, // Valor padrão é false
  });

  @override
  State<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends State<PresentScreen> {
  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dados do PIX (você pode alterar estes valores)
  final String pixQrCodeImagePath =
      'assets/images/qrcode.png'; // SUBSTITUA PELO SEU CAMINHO DO QR CODE
  final String pixCopyPasteCode =
      '08699181922'; // SUBSTITUA PELO SEU CÓDIGO PIX COPIÁVEL

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Exibir o popup após 2 segundos, APENAS SE shouldShowPixPopup for verdadeiro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.shouldShowPixPopup) {
        // Verifica o novo parâmetro do widget
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Verifica se o widget ainda está na árvore de widgets
            _showPixPopup(context);
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant PresentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Exibir o popup após 2 segundos APENAS SE shouldShowPixPopup mudar de false para true
    if (!oldWidget.shouldShowPixPopup && widget.shouldShowPixPopup) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showPixPopup(context);
        }
      });
    }
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

  // Método para exibir o popup do PIX
  void _showPixPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Impede que o popup seja fechado clicando fora
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          // AQUI ESTÁ A MUDANÇA: Definindo o maxWidth para o AlertDialog
          // Considerando que a largura do StandardScreen é 500, um maxWidth de 450
          // garante que o popup tenha um bom espaçamento interno.
          // Você pode ajustar este valor se necessário.
          // Removido insetPadding e contentPadding para usar o maxWidth
          // e padding interno do Column para controle mais preciso.
          // insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          // contentPadding: const EdgeInsets.all(20.0),
          // actionsPadding: const EdgeInsets.all(20.0),
          // Definindo uma largura máxima explícita para o AlertDialog
          // Isso garante que ele não exceda a largura da StandardScreen
          // e tenha um bom espaçamento lateral.
          // O valor 450.0 é uma sugestão, você pode ajustar.
          content: Container(
            width:
                450.0, // AQUI ESTÁ A MUDANÇA PRINCIPAL PARA LIMITAR A LARGURA
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Contribuição para os Noivos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), // Espaçamento após o título
                  Text(
                    'Olá! Se preferir fazer uma contribuição direta aos noivos via PIX, você pode usar o QR Code ou o código abaixo. Caso contrário, sinta-se à vontade para explorar nossa lista de presentes!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Imagem do QR Code
                  Image.asset(
                    pixQrCodeImagePath,
                    height: 180, // Ajuste o tamanho conforme necessário
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.qr_code_2,
                        size: 180,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Código PIX copiável
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: pixCopyPasteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Código PIX copiado!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pixCopyPasteCode,
                            style: GoogleFonts.rajdhani(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.copy, size: 20, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Botão para fechar o popup e ir para a lista de presentes
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Fecha o popup
                      },
                      child: Text(
                        'Continuar para Lista de Presentes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartItemCount = cartService.items.length;

    // Obter a largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    // Definir o breakpoint para alternar o childAspectRatio
    // Considerando que a largura do StandardScreen é 500, um breakpoint de 550
    // significa que telas menores que 550 (como a maioria dos celulares)
    // usarão 0.50, e telas maiores (como a simulação de 500px no desktop) usarão 0.64.
    final double responsiveChildAspectRatio = screenWidth > 550.0 ? 0.64 : 0.48;

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
                            quantity: (data['quantity'] ?? 0).toInt(),
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
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280.0, // Largura máxima para cada item
                    childAspectRatio:
                        responsiveChildAspectRatio, // Usando o valor responsivo
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
