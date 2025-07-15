import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Mantido para o estilo do botão
// Importe o StandardScreen para acessar seu estado
import 'package:presentes_casamento/common/widgets/standard_screen.dart';

// Não precisamos mais importar MenuScreen aqui, pois a navegação será via StandardScreen
// import 'package:presentes_casamento/modules/user/screens/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // HomeScreen é o conteúdo do body do Scaffold do StandardScreen.
    // PORTANTO, NÃO DEVE TER SEU PRÓPRIO SCAFFOLD OU APPBAR.
    return SingleChildScrollView(
      // Este SingleChildScrollView agora contém toda a Home Screen
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centraliza o conteúdo horizontalmente
        children: [
          // Imagem de Fundo que define a altura da rolagem
          Image.asset(
            'assets/images/capa2.png', // Caminho da sua imagem de fundo
            fit:
                BoxFit
                    .fitWidth, // Preenche a largura disponível, mantendo a proporção.
            // Isso fará com que a imagem se estenda verticalmente.
            width:
                MediaQuery.of(context)
                    .size
                    .width, // Garante que a imagem ocupe a largura total do Container pai (500px)
          ),

          // Espaço para posicionar o botão no "final" da imagem
          // Se a imagem for muito longa, este SizedBox empurrará o botão para baixo.
          // Ajuste este valor conforme a altura da sua imagem para que o botão fique no local desejado.
          // Exemplo: um pouco de espaço após a imagem
          // Botão MENUS - agora rola com a imagem
          SizedBox(
            width: 160,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Fundo do botão agora é branco
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Borda arredondada
                  side: const BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ), // Borda preta
                ),
              ),
              onPressed: () {
                // Encontra o estado do StandardScreen e chama changePage
                final standardScreenState =
                    context.findAncestorStateOfType<StandardScreenState>();
                if (standardScreenState != null) {
                  // O índice 3 corresponde à MenuScreen na lista de páginas do StandardScreen
                  standardScreenState.changePage(3, fromDrawer: false);
                } else {
                  // Se por algum motivo o StandardScreenState não for encontrado (o que não deveria acontecer
                  // se a estrutura estiver correta), loga um erro.
                  // Não usamos Navigator.push aqui para evitar sair do contexto do StandardScreen.
                  debugPrint(
                    'StandardScreenState não encontrado. Não foi possível navegar para MenuScreen via changePage.',
                  );
                }
              },
              child: Text(
                'Informações', // Texto do botão
                style: GoogleFonts.libreBaskerville(
                  color: Colors.black, // Cor do texto agora é preta
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50), // Espaço no final da tela após o botão
        ],
      ),
    );
  }
}
