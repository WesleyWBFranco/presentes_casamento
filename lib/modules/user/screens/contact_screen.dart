import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Para copiar para a área de transferência

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // Função para abrir URLs externas (Google Maps)
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Não foi possível abrir o link: $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Não foi possível abrir o link do mapa.'),
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

  // Função para copiar texto para a área de transferência
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Número $text copiado!'),
            backgroundColor: const Color.fromARGB(255, 122, 122, 122),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título da tela
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Text(
              'Contatos Úteis',
              style: GoogleFonts.libreBaskerville(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Seção para Missal
          _buildCitySection(
            context,
            cityName: 'Missal',
            hotels: [
              {
                'name': 'Hotel Avenida',
                'phone': '(45) 98824 7101',
                'mapLink': 'https://maps.app.goo.gl/JHhX26KgAYyHNZo89?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Hotel Michels',
                'phone': '(45) 99822 5252',
                'mapLink': 'https://maps.app.goo.gl/g9vvT46Mp3Wi2NmU9?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
            ],
            beautySalons: [
              {
                'name': 'Salão da Sol',
                'phone': '(45) 98806 3159',
                'mapLink': 'https://maps.app.goo.gl/H4FwB7WpGm4J9rn89?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Salão Monalisa',
                'phone': '(45) 99844 1279',
                'mapLink': 'https://maps.app.goo.gl/nyWJeMnV9ABdM2Kn9?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
            ],
          ),
          const SizedBox(height: 30),

          // Seção para Santa Helena
          _buildCitySection(
            context,
            cityName: 'Santa Helena',
            hotels: [
              {
                'name': 'Hotel Alvorada',
                'phone': '(45) 3268 2258',
                'mapLink': 'https://maps.app.goo.gl/Q8adSs9pwuDr5P247?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Hotel Paludo',
                'phone': '(45) 3268 1430',
                'mapLink': 'https://maps.app.goo.gl/FxtM2FVSGwtNmsQeA?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Hotel Simioni',
                'phone': '(45) 3268 1343',
                'mapLink': 'https://maps.app.goo.gl/EDTm4WbFcjfaC7qQ6?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
            ],
            beautySalons: [
              {
                'name': 'Salão da Fabrini',
                'phone': '(45) 98814 4173',
                'mapLink': 'https://maps.app.goo.gl/K2TcSV5ajTDtAouF7?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Salão da Romy',
                'phone': '(45) 3268 3236',
                'mapLink': 'https://www.google.com.br/maps/',
              }, // SUBSTITUA PELO LINK CORRETO
              {
                'name': 'Salão da Lenita',
                'phone': '(45) 3268 2115',
                'mapLink': 'https://maps.app.goo.gl/PCRsC2nEProTKgFr8?g_st=ipc',
              }, // SUBSTITUA PELO LINK CORRETO
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir a seção de uma cidade
  Widget _buildCitySection(
    BuildContext context, {
    required String cityName,
    required List<Map<String, String>> hotels,
    required List<Map<String, String>> beautySalons,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            cityName,
            style: GoogleFonts.libreBaskerville(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCategoryCard(context, title: 'Hotéis', contacts: hotels),
        const SizedBox(height: 20),
        _buildCategoryCard(
          context,
          title: 'Salão de Beleza',
          contacts: beautySalons,
        ),
      ],
    );
  }

  // Widget auxiliar para construir um card de categoria (Hotéis ou Salão)
  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required List<Map<String, String>> contacts,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.libreBaskerville(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.grey),
            ...contacts.map(
              (contact) => _buildContactItem(
                context,
                name: contact['name']!,
                phone: contact['phone']!,
                mapLink: contact['mapLink'], // Passando o mapLink individual
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir um item de contato (nome e telefone com ícone de copiar)
  Widget _buildContactItem(
    BuildContext context, {
    required String name,
    required String phone,
    String? mapLink, // mapLink agora é um parâmetro opcional
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (mapLink != null) {
                  _launchUrl(mapLink); // Usa o mapLink fornecido
                } else {
                  // Fallback ou aviso se o link não for fornecido
                  debugPrint('Link de mapa não fornecido para $name');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link do mapa não disponível.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text(
                name,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 16,
                  color: Colors.blue.shade700, // Cor de link
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          // GestureDetector para o número e o ícone de copiar
          GestureDetector(
            onTap: () => _copyToClipboard(phone),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Para que a Row ocupe o mínimo de espaço
              children: [
                Text(
                  phone,
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ), // Espaçamento entre o número e o ícone
                const Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey,
                ), // Ícone de copiar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
