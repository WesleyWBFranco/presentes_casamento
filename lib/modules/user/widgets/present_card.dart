import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/data/models/present.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentes_casamento/services/cart_services.dart';
import 'package:provider/provider.dart';

class PresentCard extends StatefulWidget {
  final Present present;
  final String documentId;
  final double imageHeight;

  const PresentCard({
    super.key,
    required this.present,
    required this.documentId,
    this.imageHeight = 150.0,
  });

  @override
  State<PresentCard> createState() => _PresentCardState();
}

class _PresentCardState extends State<PresentCard> {
  int selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.present.price * selectedQuantity;
    final isComplete = widget.present.quantity == 0;

    // Define uma altura comum para o slot do botão de quantidade/presentear
    const double actionButtonHeight =
        50.0; // Ajuste este valor conforme necessário para alinhar perfeitamente

    return Stack(
      children: [
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: SizedBox(
                  height:
                      widget
                          .imageHeight, // REVERTIDO: Usando widget.imageHeight
                  width: double.infinity, // REVERTIDO: Usando double.infinity
                  child:
                      widget.present.imagePath.isNotEmpty
                          ? Image.network(
                            widget.present.imagePath,
                            fit: BoxFit.cover, // REVERTIDO: Usando BoxFit.cover
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          )
                          : const Center(child: Icon(Icons.image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // Fixed height for the title to ensure consistent card size
                      height: 40.0, // Height to accommodate two lines of text
                      child: Text(
                        widget.present.name,
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 14, // Mantido: Tamanho da fonte do título
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2, // Mantido: Display up to two lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: actionButtonHeight, // Garante altura consistente
                      width: double.infinity,
                      child:
                          isComplete
                              ? ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                label: Text(
                                  'Presenteado',
                                  style: GoogleFonts.libreBaskerville(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor:
                                      Colors
                                          .white, // Define a cor de fundo para branco quando desabilitado
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              )
                              : PopupMenuButton<int>(
                                onSelected: (value) {
                                  setState(() {
                                    selectedQuantity = value;
                                  });
                                },
                                itemBuilder: (context) {
                                  return List.generate(
                                    widget.present.quantity,
                                    (index) {
                                      final quantity = index + 1;
                                      return PopupMenuItem(
                                        value: quantity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          'Quantidade: $quantity',
                                          style: GoogleFonts.libreBaskerville(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Quantidade: $selectedQuantity',
                                    style: GoogleFonts.libreBaskerville(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Disponível: ${widget.present.quantity}',
                          style: GoogleFonts.rajdhani(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.rajdhani(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            isComplete
                                ? null
                                : () {
                                  final cart = Provider.of<CartService>(
                                    context,
                                    listen: false,
                                  );
                                  cart.addToCart(
                                    widget.present,
                                    widget.documentId,
                                    selectedQuantity,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Adicionado ao carrinho!'),
                                    ),
                                  );
                                },
                        icon: Icon(
                          isComplete
                              ? Icons.check_circle_outline
                              : FontAwesomeIcons.gift,
                          color: isComplete ? Colors.black : Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          isComplete ? 'Presenteado' : 'Presentear',
                          style: GoogleFonts.libreBaskerville(
                            color: isComplete ? Colors.black : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isComplete ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.black,
                              width:
                                  isComplete
                                      ? 1.5
                                      : 0, // Adiciona borda se estiver completo
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isComplete)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/laço.png'),
            ),
          ),
      ],
    );
  }
}
