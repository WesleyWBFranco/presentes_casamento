import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/modules/admin/crud_screen.dart';
import 'package:presentes_casamento/modules/admin/orders_screen.dart';
import 'package:presentes_casamento/modules/admin/status_screen.dart';
import 'package:presentes_casamento/modules/user/screens/cart_screen.dart';
import 'package:presentes_casamento/modules/user/screens/home_screen.dart';
import 'package:presentes_casamento/modules/user/screens/present_screen.dart';
import 'package:presentes_casamento/modules/user/screens/menu_screen.dart';
import 'package:presentes_casamento/modules/user/screens/contact_screen.dart';
import 'package:presentes_casamento/common/widgets/countdown_display.dart'; // Importe o novo widget

class StandardScreen extends StatefulWidget {
  final Function(int)? onPageChanged;
  const StandardScreen({super.key, this.onPageChanged});

  @override
  State<StandardScreen> createState() => StandardScreenState();
}

class StandardScreenState extends State<StandardScreen> {
  int _selectedIndex = 0;
  late Future<String?> _userRoleFuture = Future.value(null);

  // Adicionado estado para controlar a exibição do popup na PresentScreen
  bool _showPixPopupOnPresentScreen = false;

  @override
  void initState() {
    super.initState();
    _userRoleFuture = _getUserRole();
    // A lógica do cronômetro foi movida para CountdownDisplay
  }

  @override
  void dispose() {
    // Não precisa cancelar o timer aqui, pois ele está no CountdownDisplay
    super.dispose();
  }

  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      return userDoc.data()?['role'] as String?;
    }
    return null;
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  // Método para mudar de página, agora aceita argumentos para PresentScreen
  void changePage(
    int index, {
    bool fromDrawer = true,
    Map<String, dynamic>? arguments,
  }) {
    setState(() {
      _selectedIndex = index;
      // Se estiver navegando para a PresentScreen (índice 1) e houver o argumento showPixPopup
      if (index == 1 &&
          arguments != null &&
          arguments['showPixPopup'] == true) {
        _showPixPopupOnPresentScreen = true;
      } else {
        _showPixPopupOnPresentScreen = false;
      }
    });
    if (fromDrawer) {
      Navigator.pop(context);
    }
    widget.onPageChanged?.call(index);
  }

  Widget _buildDrawerItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        leading: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1.0,
          child: icon,
        ),
        title: Text(
          title,
          style: GoogleFonts.libreBaskerville(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Cor das laterais
      body: Center(
        child: Container(
          width: 500, // Largura fixa simulando tela de celular
          height: 900, // Altura fixa simulando tela de celular
          decoration: BoxDecoration(
            color: Colors.white, // Fundo branco apenas no conteúdo central
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: FutureBuilder<String?>(
            future: _userRoleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userRole = snapshot.data;
              List<Widget> pages = [];
              List<Widget> drawerItems = [];

              if (userRole == 'admin') {
                pages = [
                  const StatusScreen(),
                  const CrudScreen(),
                  const OrdersScreen(),
                ];
                drawerItems = [
                  SizedBox(height: 50),
                  _buildDrawerItem(
                    icon: const Icon(Icons.timeline, color: Colors.white),
                    title: "S T A T U S",
                    onTap: () => changePage(0),
                  ),
                  SizedBox(height: 15),
                  _buildDrawerItem(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    title: "C O N F I G U R A R",
                    onTap: () => changePage(1),
                  ),
                  SizedBox(height: 15),
                  _buildDrawerItem(
                    icon: const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                    ),
                    title: "P E D I D O S",
                    onTap: () => changePage(2),
                  ),
                ];
              } else {
                // Páginas para usuários normais
                pages = [
                  const HomeScreen(),
                  // Passa o estado _showPixPopupOnPresentScreen para PresentScreen
                  PresentScreen(
                    shouldShowPixPopup: _showPixPopupOnPresentScreen,
                  ),
                  const CartScreen(),
                  const MenuScreen(), // Índice 3 (Informações)
                  const ContactScreen(), // Índice 4 (Contatos)
                ];
                drawerItems = [
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: _buildDrawerItem(
                      icon: Image.asset(
                        'assets/images/home.png',
                        color: Colors.white,
                        height: 25,
                      ),
                      title: "I N Í C I O",
                      onTap: () => changePage(0),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: _buildDrawerItem(
                      icon: Image.asset(
                        'assets/images/coração.png',
                        color: Colors.white,
                        height: 20,
                      ),
                      title: "P R E S E N T E S",
                      // Passa o argumento para ativar o popup na PresentScreen
                      onTap:
                          () =>
                              changePage(1, arguments: {'showPixPopup': true}),
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildDrawerItem(
                    icon: Image.asset(
                      'assets/images/carrinho2.png',
                      height: 30,
                      color: Colors.white,
                    ),
                    title: "C A R R I N H O",
                    onTap: () => changePage(2),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: _buildDrawerItem(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ), // Ícone de informações com borda
                      title: "I N F O R M A Ç Õ E S", // Texto alterado
                      onTap: () => changePage(3), // Índice da MenuScreen
                    ),
                  ),
                ];
              }

              return Scaffold(
                backgroundColor: Colors.white, // Fundo do Scaffold interno
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  leading: Builder(
                    builder:
                        (context) => IconButton(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Icon(Icons.menu, color: Colors.white),
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                  ),
                  // CRONÔMETRO AQUI COMO TÍTULO CENTRAL (UMA ÚNICA LINHA)
                  title: const CountdownDisplay(), // Usa o novo widget aqui
                  centerTitle: true, // Centraliza o título
                  actions: <Widget>[
                    if (userRole == 'user')
                      IconButton(
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Image.asset(
                            'assets/images/carrinho2.png',
                            color: Colors.white,
                            height: 30,
                          ),
                        ),
                        onPressed: () => changePage(2, fromDrawer: false),
                      ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: DrawerHeader(
                              child: Image.asset(
                                'assets/images/presente.png',
                                color: Colors.white,
                                height: 80, // Ajustado para ser mais visível
                              ),
                            ),
                          ),
                          ...drawerItems,
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          bottom: 25.0,
                        ),
                        child: GestureDetector(
                          onTap: logout,
                          child: ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Sair',
                              style: GoogleFonts.libreBaskerville(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: IndexedStack(index: _selectedIndex, children: pages),
              );
            },
          ),
        ),
      ),
    );
  }
}
