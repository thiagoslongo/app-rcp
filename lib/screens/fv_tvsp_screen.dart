import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../widgets/medical_action_card_tvsp.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';  

class FvTvspScreen extends StatefulWidget {
  const FvTvspScreen({super.key});

  @override
  FvTvspScreenState createState() => FvTvspScreenState();
}

class FvTvspScreenState extends State<FvTvspScreen> {
  bool isRunning = false;
  int cycles = 0;
  int secondsPassed = 0;
  Timer? timer;
  int shockCount = 0;
  int epinefrinaDoses = 0;
  int amiodaronaDoses = 0;
  final PageController pageController = PageController();
  final AudioPlayer audioPlayer = AudioPlayer();  // Para tocar o som de notificação
  
  // Controla se já mostrou a dica de instrução
  bool hasShownStarterTip = false;

  List<bool> isCheckedList = List.generate(13, (_) => false);
  List<bool> isCheckedListtwo = List.generate(12, (_) => false);
  List<bool> isCheckedListthree = List.generate(12, (_) => false);
  List<bool> isCheckedListfour = List.generate(12, (_) => false);
  List<bool> isCheckedListfive = List.generate(13, (_) => false);
  List<bool> isCheckedListsix = List.generate(13, (_) => false);

  @override
  void initState() {
    super.initState();
    
    // Mostrar a dica inicial após um breve atraso para dar tempo do widget renderizar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasShownStarterTip) {
        _showStarterTip();
      }
    });
  }

  // Mostra dica para usuários novos sobre iniciar o cronômetro
  void _showStarterTip() {
    setState(() {
      hasShownStarterTip = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Como iniciar'),
        content: const Text(
          'Para iniciar o atendimento, clique no botão "Compressão Torácica" para ativar o cronômetro e começar a contagem dos ciclos.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String getFormattedTime() {
    int minutes = secondsPassed ~/ 60;
    int seconds = secondsPassed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimerStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getFormattedTime(),
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          'Ciclos: $cycles',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        setState(() {
          secondsPassed++;
          if (secondsPassed % 120 == 0 && secondsPassed != 0) {
            cycles++;
            _playNotificationSound();
          }
        });
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  // Função para tocar o som de notificação
  Future<void> _playNotificationSound() async {
    try {
      HapticFeedback.heavyImpact(); // Vibração para reforçar a notificação

      // No Android, pode usar este método para tocar som padrão do sistema
      await SystemChannels.platform.invokeMethod('SystemSound.play', 'notification');
      print('Som de notificação reproduzido');

    } catch (e) {
      print('Erro ao tocar som: $e');

      HapticFeedback.vibrate();
    }
  }

  void showReport() {
    String generateReport() {
      final StringBuffer report = StringBuffer();
      // Cabeçalho do relatório
      report.writeln('Relátório de atendimento FV/TVSP\n');
      report.writeln('Tempo total: ${getFormattedTime()}');
      report.writeln('Ciclos completados: $cycles');
      report.writeln('Choques aplicados: $shockCount');
      report.writeln('Doses de Epinefrina: $epinefrinaDoses');
      report.writeln('Doses de Amiodarona: $amiodaronaDoses\n');
      

      // Procedimentos Iniciais
      report.writeln('1. Procedimentos Iniciais:');
      final checkboxTexts1 = [
        'Verificar o pulso por 10s: pulso carotídeo ou femoral',
        'Chamar ajuda e iniciar imediatamente a RCP',
        'Iniciar compressões: 30 compressões para 2 ventilações',
        'Iniciar as compressões no terço inferior do esterno',
        'As compressões deprimem o tórax em 5cm',
        'As compressões permitem retorno do tórax P',
        'Delegar para pegar o carro de emergência',
        'Monitorar paciente com pás do desfibrilador',
        'Observar monitor - FV/TVSP',
        'Retomar compressões',
        'Ciclos de 30 compressões para 2 ventilações com bolsa, válvula, máscara',
        'Ligar fonte de oxigênio a 15 l/min'
      ];
      
      for (int i = 0; i < checkboxTexts1.length; i++) {
        if (isCheckedList[i]) {
          report.writeln('✓ ${checkboxTexts1[i]}');
        }
      }

      // Acesso Venoso e Primeiro Choque
      report.writeln('\n2. Acesso Venoso e Primeiro Choque:');
      final checkboxTexts2 = [
        'Verificar se reservatório de oxigênio está enchendo',
        'Solicitar acesso venoso periférico durante as compressões',
        'Abocath 18',
        'Abocath 20',
        'Torneirinha',
        'Realizar monitorização com eletrodos do desfibrilador',
        'Verificar pulso e analisar ritmo após 5 ciclos',
        'Realizar 1° Choque',
        'Ajustar carga do desfibrilador',
        'Bifásico 200J',
        'Monofásico 360J'
      ];
      
      for (int i = 0; i < checkboxTexts2.length; i++) {
        if (isCheckedListtwo[i]) {
          report.writeln('✓ ${checkboxTexts2[i]}');
        }
      }

      // Via Aérea e Medicação
      report.writeln('\n3. Via Aérea e Medicação:');
      final checkboxTexts3 = [
        'Verificar pulso e analisar ritmo após 5 ciclos',
        'Realizar 2° Choque',
        'Continuar compressões',
        'Administrar epinefrina 1mg',
        'Preparar epinefrina',
        'Administrar com flush de 20ml SF',
        'Elevar membro',
        'Solicitar via aérea avançada',
        'Via aérea avançada estabelecida'
      ];
      
      for (int i = 0; i < checkboxTexts3.length; i++) {
        if (isCheckedListthree[i]) {
          report.writeln('✓ ${checkboxTexts3[i]}');
        }
      }

      // Terceiro Choque e Amiodarona
      report.writeln('\n4. Terceiro Choque e Amiodarona:');
      final checkboxTexts4 = [
        'Ventilação a cada 6 segundos',
        'Manter O2 a 15 l/min',
        'Compressões contínuas por 2 minutos',
        'Verificar pulso e ritmo',
        'Realizar 3° Choque',
        'Administrar amiodarona 300mg',
        'Preparar amiodarona',
        'Administrar com flush de 20ml SF',
        'Elevar membro',
        'Verificar pulso e ritmo após 2 min'
      ];
      
      for (int i = 0; i < checkboxTexts4.length; i++) {
        if (isCheckedListfour[i]) {
          report.writeln('✓ ${checkboxTexts4[i]}');
        }
      }

      // Quarto e Quinto Choques
      report.writeln('\n5. Quarto e Quinto Choques:');
      final checkboxTexts5 = [
        'Analisar ritmo - FV/TVSP',
        'Realizar 4° Choque',
        'Administrar epinefrina 1mg',
        'Preparar epinefrina',
        'Administrar com flush de 20ml SF',
        'Verificar pulso e ritmo após 2 min',
        'Realizar 5° Choque',
        'Administrar amiodarona 150mg',
        'Preparar amiodarona'
      ];
      
      for (int i = 0; i < checkboxTexts5.length; i++) {
        if (isCheckedListfive[i]) {
          report.writeln('✓ ${checkboxTexts5[i]}');
        }
      }

      // Sexto Choque e Desfecho
      report.writeln('\n6. Sexto Choque e Desfecho:');
      final checkboxTexts6 = [
        'Administrar com flush de 20ml SF',
        'Elevar membro',
        'Verificar pulso e ritmo após 2 min',
        'Realizar 6° Choque',
        'Continuar compressões',
        'Verificar pulso final',
        'Presença de pulso',
        'Monitorar sinais vitais',
        'Instalar drogas vasoativas'
      ];
      
      for (int i = 0; i < checkboxTexts6.length; i++) {
        if (isCheckedListsix[i]) {
          report.writeln('✓ ${checkboxTexts6[i]}');
        }
      }

      return report.toString();
    }

    void shareReport() {
      final String reportText = generateReport();
      Share.share(reportText, subject: 'Relatório de Atendimento FV/TVSP');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Relatório de Atendimento'),
        content: SingleChildScrollView(
          child: Text(generateReport()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              shareReport();
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  void administerShock() {
    setState(() {
      shockCount++;
    });
  }

  // Função para navegar para a primeira página (ações)
  void _navigateToActionsPage() {
    pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
      if (!didPop) {
        // ignore: unused_element, no_leading_underscores_for_local_identifiers
        Future<bool> _onWillPop() async {
          if (pageController.page != 0) {
            // Se não estiver na primeira página, navega para ela
              _navigateToActionsPage();
                return false; // Impede que o app saia ou volte à tela anterior
      }
       return true; // Permite o comportamento normal de voltar
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              const Text(
                AppStrings.fvTvsp,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Cronômetro e contador de ciclos com mesmo estilo do título
              Expanded(
                child: Text(
                  '${getFormattedTime()}  •  Ciclos: $cycles',
                  style: const TextStyle(
                    fontSize: 18, // Mesmo tamanho do título
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, // Alinhado à esquerda
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (pageController.page != 0) {
                _navigateToActionsPage();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: PageView(
          controller: pageController,
          children: [
            _buildActionsPage(),
            _buildFirstChecklistPage(),
            _buildSecondChecklistPage(),
            _buildThirdChecklistPage(),
            _buildFourChecklistPage(),
            _buildFiveChecklistPage(),
            _buildSixChecklistPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsPage() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Widget para mostrar uma dica visual se o cronômetro ainda não estiver ativo
        if (!isRunning)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Clique em 'Compressão Torácica' para iniciar o cronômetro e a contagem de ciclos",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      // Remover a dica
                      hasShownStarterTip = true;
                    });
                  },
                ),
              ],
            ),
          ),
        MedicalActionCardTvsp(
          title: "Compressão Torácica",
          icon: Icons.favorite,
          onPressed: toggleTimer,
          description: isRunning 
              ? "100 a 120 compressões por minuto\nAlternar socorrista a cada 2 min."
              : "Clique para iniciar o cronômetro\n100 a 120 compressões por minuto",
          statsWidget: _buildTimerStats(),
          // Cor verde quando o cronômetro estiver ativo
          buttonColor: isRunning ? Colors.green : AppColors.primary,
          textColor: Colors.black,
          iconColor: Colors.white,
        ),
        const SizedBox(height: 0),
        AbsorbPointer(
          absorbing: true,
          child: MedicalActionCardTvsp(
            title: "Ventilações",
            icon: Icons.air,
            onPressed: () {},
            description: "AMBU: 2 ventilações / 30 compressões\nIOT: 10 ventilações/minuto",
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardTvsp(
          title: "Desfibrilação",
          icon: Icons.bolt,
          onPressed: administerShock,
          description: "Aplicar choque de 200J\nReiniciar RCP imediatamente após o choque",
          statsWidget: Text(
            'Choques aplicados: $shockCount',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardTvsp(
          title: "Epinefrina",
          icon: Icons.medical_services,
          onPressed: () {
            setState(() {
              epinefrinaDoses++;
            });
          },
          description: "Administrar a cada 3-5 minutos",
          statsWidget: Text(
            "Doses: $epinefrinaDoses", 
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardTvsp(
          title: "Amiodarona",
          icon: Icons.medical_services,
          onPressed: () {
            if (amiodaronaDoses < 2) { 
            setState(() {
              amiodaronaDoses++;
            });
          }
       },
          description: "Após o 3° choque 300mg \nApós o 5° choque 150mg",
          statsWidget: Text(
            "Doses: $amiodaronaDoses",
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardTvsp(
          title: "Gerar Relatório",
          icon: Icons.description,
          onPressed: showReport,
          description: "Visualizar resumo do atendimento",
        ),
      ],
    );
  }

  Widget _buildFirstChecklistPage() {
    final checkboxTexts = [
      'Verificar o pulso por 10s: pulso carotídeo ou femoral',
      'Chamar ajuda e iniciar imediatamente a RCP',
      'Iniciar compressões: 30 compressões para 2 ventilações:',
      'Iniciar compressões no terço inferior do esterno',
      'As compressões deprimem o tórax em 5cm',
      'As compressões permitem retorno do tórax P',
      'Delegar para pegar o carro de emergência',
      'Monitorar paciente com as pás do desfibrilador',
      'Observar monitor - FV/TVSP',
      'Retomar compressões',
      'Ciclos de 30 compressões para 2 ventilações com bolsa, válvula, máscara.',
      'Ligar fonte de oxigênio a 15 l/min:',
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedList,
      [3, 4, 5, 10, 12],
    );
  }

  Widget _buildSecondChecklistPage() {
    final checkboxTexts = [
      'Verificar se reservatório de oxigênio está enchendo',
      'Solicitar acesso venoso periférico durante as compressões:',
      'Abocath 18',
      'Abocath 20',
      'Torneirinha',
      'Realizar monitorização com eletrodos do desfibrilador enquanto são realizadas as compressões',
      'Após 5 cliclos de RCP, veriricar o pulso e analisar o ritmo por no máximo 10 segundos.',
      'Realizar o 1° Choque',
      'FALAR EM VOZ ALTA, ajustar carga do desfibrilador',
      'Bifásico 200J',
      'Monofásico 360J',
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedListtwo,
      [0, 1, 7],
    );
  }

  Widget _buildThirdChecklistPage() {
    final checkboxTexts = [
      'Após 5 ciclos de RCP, verificar o pulso e analisar o ritmo por máximo 10 segundos.',
      'Realizar o 2° Choque',
      'Continuar as compressões',
      'Iniciar epinefrina 1 mg durante as compressões e repeti-la a cada 3-5 minutos',
      'FALAR EM VOZ ALTA: administrar epinefrina 1 mg',
      'FALAR EM VOZ ALTA: preparando 1 mg de epinefrina',
      'Aspirar adrenalina em uma seringa de 3ml',
      'Aspirar 20 ml de soro fisiológico em uma seringa de 20 ml',
      'Elevar membro',
      'Solicitar via aérea avançada COM MÁSCARA DE LARÍNGEA ou IOT',
      'Realizou com sucesso a via aérea avançada o FALAR EM VOZ ALTA: VIA AÉREA AVANÇADA PRONTA',
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedListthree,
      [2,4,5,6,7 ],
    );
  }

  Widget _buildFourChecklistPage() {
    final checkboxTexts = [
      '01 ventilação a cada 06 segundos',
      'Manter fonte de oxigênio a 15 l/min',
      'SOLICITAR INÍCIO DE compressões contínuas por dois minutos e 01 ventilação a cada seis segundos',
      'Chegar pulso e analisar o ritmo por no máximo 10 segundos.',
      'Após 2min de RCP, verificar o pulso e analisar o ritmo por máximo 10 segundos.',
      'Realizar o 3° Choque',
      'FALAR EM VOZ ALTA: administrar amiodarona 300mg',
      'FALAR EM VOZ ALTA: preparando 300mg de amiodarona',
      'Aspirar 20 ml de soro fisiológico em uma seringa de 20ml',
      'Elevar membro',
      'Após 2 min de RCP, verificar o pulso e analisar o ritmo por no máximo 10 segundos no monitor',
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedListfour,
      [6,7,8],
    );
  }

  Widget _buildFiveChecklistPage() {
    final checkboxTexts = [
      'Analisar o ritmo, paciente mantem em FV/TVSP',
      'Realizar o 4° Choque',
      'FALAR EM VOZ ALTA: administrar epinefrina 1mg',
      'FALAR EM VOZ ALTA: preparando 1mg de epinefrina',
      'Aspirar adrenalina em uma seringa de 3ml',
      'Aspirar 20 ml de soro fisiológico em uma seringa de 20ml',
      'Elevar o membro',
      'Após 2min de RCP, verificar o pulso e analisar o ritmo por no máximo 10 segundos no monitor.',
      'Analisar o ritmo, paciente mantem em FV/TVSP',
      'Realizar o 5° Choque',
      'FALAR EM VOZ ALTA: administrar amiodarona 150mg',
      'FALAR EM VOZ ALTA: preparando 150mg de amiodarona'
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedListfive,
      [2,3,4,5,10,11],
    );
  }

  Widget _buildSixChecklistPage() {
    final checkboxTexts = [
      'Aspirar 20 ml de soro fisiológico em uma seringa de 20ml',
      'Elevar o membro',
      'Após 2min de RCP, verificar o pulso e analisar o ritmo por no máximo 10 segundos no monitor.',
      'Analisar o ritmo, paciente mantem em FV/TVSP',
      'Realizar o 6° Choque',
      'Continuar as compressões',
      'Após 2min de RCP, verificar o pulso e analisar o ritmo por no máximo 10 segundos no monitor.',
      'Presença de pulso:',
      'Monitorar os sinais vitais e instalar drogas vasoativas',
    ];

    return _buildChecklistPageTemplate(
      checkboxTexts,
      isCheckedListsix,
      [0,4,5,7],
    );
  }

  Widget _buildChecklistPageTemplate(
    List<String> texts,
    List<bool> checkedList,
    List<int> excludeIndices,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ListView.builder(
        itemCount: texts.length,
        itemBuilder: (context, index) {
          final bool isExcluded = excludeIndices.contains(index);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: ListTile(
              title: Text(
                texts[index],
                style: const TextStyle(fontSize: 15.0),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
              trailing: isExcluded
                  ? null
                  : Checkbox(
                      value: checkedList[index],
                      activeColor: Colors.green,
                      onChanged: (bool? value) {
                        setState(() {
                          checkedList[index] = value!;
                        });
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}