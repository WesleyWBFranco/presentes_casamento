import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Importe para usar Timer e Duration

class CountdownDisplay extends StatefulWidget {
  const CountdownDisplay({super.key});

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay> {
  late Timer _timer;
  Duration _timeLeft = const Duration();
  final DateTime weddingDate = DateTime(
    2025,
    9,
    20,
    17,
    0,
  ); // Data do casamento

  @override
  void initState() {
    super.initState();
    _startCountdown(); // Inicia o cronômetro aqui
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancela o timer ao descartar o widget
    super.dispose();
  }

  // Inicia o timer para o contador regressivo
  void _startCountdown() {
    _timeLeft = weddingDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Verifica se o widget ainda está montado antes de chamar setState
        setState(() {
          _timeLeft = weddingDate.difference(DateTime.now());
          if (_timeLeft.isNegative) {
            _timer.cancel();
          }
        });
      }
    });
  }

  // Formata a duração para exibir Dias : Horas : Minutos : Segundos com unidades
  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '0 dias : 0 horas : 0 min : 0 seg'; // Se a data já passou, exibe zero
    }
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    return '$days dias : $hours horas : $minutes min : $seconds seg';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_timeLeft), // Exibe o cronômetro formatado
      style: GoogleFonts.rajdhani(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center, // Centraliza o texto
    );
  }
}
