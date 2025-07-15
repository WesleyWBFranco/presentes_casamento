import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Importe para abrir URLs
import 'package:presentes_casamento/common/widgets/standard_screen.dart'; // Para acessar changePage
import 'package:presentes_casamento/modules/user/screens/contact_screen.dart'; // Importe a ContactScreen

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Função para abrir URLs externas
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint(
          'Não foi possível abrir o link (launchUrl retornou false): $url',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erro: Não foi possível abrir o link. Verifique a URL ou se você tem um navegador/app de mapas.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao tentar abrir o link $url: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir o link: ${e.toString()}.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // A MenuScreen é renderizada dentro do StandardScreen,
    // que já fornece o Container com dimensões fixas e bordas.
    // Portanto, não precisamos de um Scaffold próprio aqui.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .center, // Centraliza o conteúdo horizontalmente
          children: [
            // Primeira linha de cards (Localização da Igreja e Localização da Festa)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly, // Distribui o espaço igualmente
              children: [
                Expanded(
                  // Faz o card expandir para preencher o espaço disponível
                  child: _buildCard(
                    iconWidget: Image.asset(
                      // Usando Image.asset aqui
                      'assets/images/igreja.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 180, // AUMENTADO o tamanho da imagem
                    ),
                    title: 'Localização da Igreja',
                    buttonText: 'Acessar',
                    onPressed: () {
                      // Link para a localização da Igreja no Google Maps
                      _launchUrl('https://maps.app.goo.gl/FqQGdz3brF1zhyE78');
                    },
                  ),
                ),
                const SizedBox(width: 15), // Espaçamento entre os cards
                Expanded(
                  // Faz o card expandir para preencher o espaço disponível
                  child: _buildCard(
                    iconWidget: Image.asset(
                      // Usando Image.asset aqui
                      'assets/images/festa.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 180, // AUMENTADO o tamanho da imagem
                    ),
                    title: 'Localização da Festa',
                    buttonText: 'Acessar',
                    onPressed: () {
                      // Link para a localização da Festa no Google Maps
                      _launchUrl('https://maps.app.goo.gl/HYjaUHja6br5E137A');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Espaçamento entre as linhas de cards
            // Segunda linha de cards (Contatos e Presentes)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly, // Distribui o espaço igualmente
              children: [
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      // Usando Image.asset aqui
                      'assets/images/contato.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 180, // AUMENTADO o tamanho da imagem
                    ),
                    title: 'Contatos de Referência',
                    buttonText: 'Acessar',
                    onPressed: () {
                      // Navega para a tela de Contatos (índice 4 no StandardScreen)
                      final standardScreenState =
                          context
                              .findAncestorStateOfType<StandardScreenState>();
                      if (standardScreenState != null) {
                        standardScreenState.changePage(
                          4,
                          fromDrawer: false,
                        ); // ContactScreen é o índice 4
                      } else {
                        debugPrint(
                          'StandardScreenState não encontrado. Não foi possível navegar para Contatos.',
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Erro: Não foi possível navegar para a tela de Contatos.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 15), // Espaçamento entre os cards
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      // Usando Image.asset aqui
                      'assets/images/presentes.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 180, // AUMENTADO o tamanho da imagem
                    ),
                    title: 'Lista de Presentes',
                    buttonText: 'Acessar',
                    onPressed: () {
                      // Navega para a tela de Presentes (índice 1 no StandardScreen)
                      final standardScreenState =
                          context
                              .findAncestorStateOfType<StandardScreenState>();
                      if (standardScreenState != null) {
                        standardScreenState.changePage(
                          1,
                          fromDrawer: false,
                        ); // PresentScreen é o índice 1
                      } else {
                        debugPrint(
                          'StandardScreenState não encontrado. Não foi possível navegar para Presentes.',
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Erro: Não foi possível navegar para a tela de Presentes.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espaçamento inferior
          ],
        ),
      ),
    );
  }

  // Widget auxiliar unificado para construir todos os cards
  // Agora aceita um Widget para o ícone
  Widget _buildCard({
    required Widget iconWidget, // Alterado de IconData para Widget
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0, // Sem sombra para o fundo branco/transparente
      margin:
          EdgeInsets
              .zero, // Remove a margem padrão do Card para controlar o espaçamento com SizedBox
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Colors.black,
          width: 1.5,
        ), // Borda preta de 1.5pt
      ),
      color: Colors.white, // Fundo branco do card
      // REMOVIDO O INKWELL QUE ENVOLVIA O CARD INTEIRO
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            iconWidget, // Usando o Widget diretamente aqui
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.libreBaskerville(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Adicionado um SizedBox para alongar o card
            const SizedBox(
              height: 25,
            ), // AUMENTADO o espaçamento para alongar o card
            SizedBox(
              width: double.infinity, // Preenche a largura do card
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // O ElevatedButton já tem seu próprio efeito de clique (splash/highlight)
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
