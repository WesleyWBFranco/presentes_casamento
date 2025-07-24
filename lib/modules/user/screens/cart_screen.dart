import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/common/widgets/standard_screen.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:presentes_casamento/services/cart_services.dart';
import 'package:flutter/services.dart'; // Para Clipboard

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isConfirming = false;
  OverlayEntry? _confirmationOverlay;

  // Dados do PIX para a tela de confirmação
  final String pixQrCodeImagePath =
      'assets/images/qrcode2.png'; // Caminho do seu QR Code
  final String pixCopyPasteCode =
      'brunalnervis2018@gmail.com'; // Chave PIX aleatória, você pode alterar

  Future<void> _confirmCart(
    BuildContext context,
    CartService cartService,
  ) async {
    setState(() {
      _isConfirming = true;
    });

    try {
      await cartService.savePurchaseHistory();
      await cartService.confirmPurchaseAndUpdateFirebase();
      if (mounted) {
        _showConfirmationAnimation(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar a compra: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  void _showConfirmationAnimation(BuildContext context) {
    _confirmationOverlay = OverlayEntry(
      builder:
          (context) => Container(
            color: Colors.white,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _hideConfirmationAnimation();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/giftConfirmation.json',
                      width: 550,
                      height: 550,
                      repeat: false,
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        // Garante que o conteúdo dentro do Padding esteja centralizado
                        child: Text(
                          'OBRIGADO POR FAZER PARTE DO NOSSO SONHO!',
                          textAlign:
                              TextAlign
                                  .center, // Garante centralização do texto
                          style: GoogleFonts.libreBaskerville(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_confirmationOverlay!);

    Future.delayed(const Duration(seconds: 5), () {
      _hideConfirmationAnimation();
    });
  }

  void _hideConfirmationAnimation() {
    if (_confirmationOverlay != null) {
      _confirmationOverlay?.remove();
      _confirmationOverlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartItems = cartService.items;
    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.present.price * item.selectedQuantity),
    );

    final cartScreenContext = context;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body:
          cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/presente_vazio.png',
                      width: 250,
                      height: 250,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Seu carrinho está vazio.',
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 150),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.present.imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      title: Text(
                        item.present.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        'R\$ ${(item.present.price * item.selectedQuantity).toStringAsFixed(2)}',
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
                            icon: const Icon(Icons.remove, color: Colors.black),
                            onPressed: () => cartService.decreaseQuantity(item),
                          ),
                          Text(
                            '${item.selectedQuantity}',
                            style: GoogleFonts.libreBaskerville(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.black),
                            onPressed: () => cartService.increaseQuantity(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          cartItems.isEmpty
              ? SizedBox(
                width: 350,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final standardScreenState =
                        context.findAncestorStateOfType<StandardScreenState>();
                    if (standardScreenState != null) {
                      standardScreenState.changePage(1, fromDrawer: false);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StandardScreen(),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver Lista de Presentes',
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SizedBox(
                width: 350,
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                // Definindo o maxWidth para o AlertDialog
                                // para respeitar os limites da StandardScreen
                                content: Container(
                                  width:
                                      450.0, // Largura máxima para o conteúdo do AlertDialog
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Confirmação de Pagamento',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.libreBaskerville(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Image.asset(
                                          pixQrCodeImagePath,
                                          height: 180,
                                          width: 180,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.qr_code_2,
                                              size: 180,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: pixCopyPasteCode,
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Chave PIX copiada!',
                                                ),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              ),
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
                                                const Icon(
                                                  Icons.copy,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Total: R\$ ${totalAmount.toStringAsFixed(2)}',
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Escaneie o QR Code ou clique em "Copiar Chave PIX". Abra o aplicativo do seu banco, selecione a opção PIX, cole a chave ou use a leitura de QR Code, coloque o valor do presente e confirme o pagamento do valor total. Não se esqueça de clicar em "Confirmar" aqui no aplicativo após o pagamento!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.libreBaskerville(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            side: MaterialStateProperty.all<
                                              BorderSide
                                            >(
                                              const BorderSide(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                            ),
                                            padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry
                                            >(
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
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
                                          onPressed:
                                              () => Navigator.pop(context),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await _confirmCart(
                                              cartScreenContext,
                                              cartService,
                                            );
                                          },
                                          child: Text(
                                            'Confirmar',
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
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isConfirming
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Row(
                                children: [
                                  Text(
                                    'Confirmar - ',
                                    style: GoogleFonts.libreBaskerville(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
    );
  }
}
