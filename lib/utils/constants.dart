import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 0, 0, 0);
  static const Color background = Color(0xFFF3F4F6);
  static const Color white = Colors.white;
  static const Color black87 = Colors.black87;
}

class AppStrings {
  static const String appTitle = "App Treinamento RCP";
  static const String fvTvsp = "FV / TVSP";
  static const String aespAssistolia = "AESP / ASSISTOLIA";
  static const String instructionsTitle = "Instruções de Uso";
  static const String instructionsText = "Este app auxilia estudantes e profissionais da saúde em paradas cardiorrespiratórias.";
  static const String instructionsSteps = "\t 1. Identifique o ritmo no monitor.\n"
      "\t 2. Toque em \"Compressões\" para iniciar o cronômetro e marcar os ciclos.\n"
      "\t 3. Arraste para a esquerda para acessar o check-list com 3 telas. Marque os itens realizados.\n"
      "\t 4. Arraste para a direita para voltar ao cronômetro.\n"
      "\t 5. Após administrar epinefrina, clique no botão correspondente.\n"
      "\t 6. Finalize tocando em \"Compressões\" para pausar e visualizar o resumo.";
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: AppColors.white,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle instructionsTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle instructionsBody = TextStyle(
    fontSize: 16,
    color: AppColors.black87,
  );
}