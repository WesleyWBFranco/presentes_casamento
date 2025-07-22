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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .center, // Centraliza o conteúdo horizontalmente
          children: [
            // NOVA PRIMEIRA LINHA: Lista de Presentes (sozinha e centralizada)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza o card
              children: [
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      'assets/images/presentes.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 150, // Tamanho da imagem um pouco menor
                    ),
                    title: 'Lista de Presentes',
                    buttonText: 'Acessar',
                    onPressed: () {
                      final standardScreenState =
                          context
                              .findAncestorStateOfType<StandardScreenState>();
                      if (standardScreenState != null) {
                        standardScreenState.changePage(
                          1, // Índice da PresentScreen
                          fromDrawer: false,
                          arguments: {'showPixPopup': true},
                        );
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
            const SizedBox(height: 20), // Espaçamento entre as linhas de cards
            // SEGUNDA LINHA: Localização da Igreja e Localização da Festa
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly, // Distribui o espaço igualmente
              children: [
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      'assets/images/igreja.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 150, // Tamanho da imagem um pouco menor
                    ),
                    title: 'Localização da Igreja',
                    buttonText: 'Acessar',
                    onPressed: () {
                      _launchUrl('https://maps.app.goo.gl/FqQGdz3brF1zhyE78');
                    },
                  ),
                ),
                const SizedBox(width: 15), // Espaçamento entre os cards
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      'assets/images/festa.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 150, // Tamanho da imagem um pouco menor
                    ),
                    title: 'Localização da Festa',
                    buttonText: 'Acessar',
                    onPressed: () {
                      _launchUrl('https://maps.app.goo.gl/HYjaUHja6br5E137A');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espaçamento entre as linhas de cards
            // TERCEIRA LINHA: Lista de Presença e Contatos Úteis
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly, // Distribui o espaço igualmente
              children: [
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      'assets/images/presença.png', // SUBSTITUA AQUI PELO CAMINHO DA SUA IMAGEM
                      height: 150, // Tamanho da imagem um pouco menor
                    ),
                    title: 'Lista de Presença',
                    buttonText: 'Acessar',
                    onPressed: () {
                      _launchUrl('https://forms.gle/WqYn3VXgcsCYArbD8');
                    },
                  ),
                ),
                const SizedBox(width: 15), // Espaçamento entre os cards
                Expanded(
                  child: _buildCard(
                    iconWidget: Image.asset(
                      'assets/images/contato.png', // SUBSTITUA PELO SEU CAMINHO CORRETO
                      height: 150, // Tamanho da imagem um pouco menor
                    ),
                    title: 'Contatos Úteis',
                    buttonText: 'Acessar',
                    onPressed: () {
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
              ],
            ),
            const SizedBox(height: 20), // Espaçamento inferior
          ],
        ),
      ),
    );
  }

  // Widget auxiliar unificado para construir todos os cards
  Widget _buildCard({
    required Widget iconWidget,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      color: Colors.white,
      child: Container(
        height:
            280, // Altura fixa para o conteúdo do card (diminuída de 310 para 280)
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 10),
            SizedBox(
              height: 40, // Altura fixa para o texto (acomoda 1 ou 2 linhas)
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 13, // Fonte um pouco menor
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
