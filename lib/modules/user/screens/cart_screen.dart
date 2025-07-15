import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/common/widgets/standard_screen.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:presentes_casamento/services/cart_services.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isConfirming = false;
  OverlayEntry? _confirmationOverlay;

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
                      'assets/animations/giftAnimation.json',
                      width: 350,
                      height: 350,
                      repeat: false,
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Obrigado por fazer parte do nosso Sonho!',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text(
            'Seu Carrinho',
            style: GoogleFonts.libreBaskerville(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
        ),
      ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 18,
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
                            style: GoogleFonts.rajdhani(
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
                                title: Text(
                                  'Confirmar Presentes',
                                  style: GoogleFonts.libreBaskerville(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 24),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pix:  ',
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SelectableText(
                                          '08699181922',
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        TextButton.icon(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              const ClipboardData(
                                                text: '08699181922',
                                              ),
                                            );
                                            if (cartScreenContext.mounted) {
                                              ScaffoldMessenger.of(
                                                cartScreenContext,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Chave Pix copiada!',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            'Copiar Chave',
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Total: R\$ ${totalAmount.toStringAsFixed(2)}',
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: 130,
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
                                  SizedBox(
                                    width: 130,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                      ),
                                      child: Text(
                                        'Confirmar',
                                        style: GoogleFonts.libreBaskerville(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _confirmCart(
                                          cartScreenContext,
                                          cartService,
                                        ); // Use o contexto capturado
                                      },
                                    ),
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
