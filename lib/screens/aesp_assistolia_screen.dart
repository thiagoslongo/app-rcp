import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/medical_action_card_aesp.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

class ChecklistItem {
  final String text;
  bool isChecked;

  ChecklistItem({required this.text, this.isChecked = false});
}

class ChecklistSection {
  final String title;
  final List<ChecklistItem> items;

  ChecklistSection({required this.title, required this.items});
}

class AespAssistoliaScreen extends StatefulWidget {
  const AespAssistoliaScreen({super.key});

  @override
  AespAssistoliaScreenState createState() => AespAssistoliaScreenState();
}

class AespAssistoliaScreenState extends State<AespAssistoliaScreen>
    with SingleTickerProviderStateMixin {
  bool isRunning = false;
  int cycles = 0;
  int secondsPassed = 0;
  int epinephrineDoses = 0;
  Timer? timer;
  final PageController pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

  // Controla se já mostrou a dica de instrução
  bool hasShownStarterTip = false;

  // Pré-inicialize seus textos para evitar reconstruções desnecessárias
  final List<String> firstChecklistTexts = [
    'Verificar o pulso por 10s: pulso carotídeo ou femoral',
    'Chamar ajuda e iniciar imediatamente a RCP',
    'Iniciar compressões: 30 compressões para 2 ventilações:',
    'Iniciar compressões no terço inferior do esterno',
    'As compressões deprimem o tórax em 5cm',
    'As compressões permitem retorno do tórax P',
    'Delegar para pegar o carro de emergência',
    'Monitorar paciente com as pás do desfibrilador',
    'Observar monitor. Se linha reta: assistolia',
    'Retomar compressões',
    'Ciclos de 30 compressões para 2 ventilações com bolsa, válvula, máscara.',
    'Ligar fonte de oxigênio a 15 l/min:',
    'Verificar se reservatório de oxigênio está enchendo',
  ];

  final List<String> secondChecklistTexts = [
    'Solicitar acesso venoso periférico durante as compressões:',
    'Abocath 18',
    'Abocath 20',
    'Torneirinha',
    'Realizar monitorização com eletrodos do desfibrilador enquanto são realizadas as compressões',
    'Após 5 ciclos de RCP, verificar o pulso e analisar o ritmo por máximo 10 segundos.',
    'SE MANTÉM AUSÊNCIA DE PULSO',
    'Iniciar epinefrina 1 mg durante as compressões e repeti-la a cada 3-5 minutos',
    'Falar em voz alta: administrar epinefrina 1 mg a cada 4 minutos',
    'Falar em voz alta: preparando 1 mg de epinefrina',
    'Aspirar adrenalina em uma seringa de 3ml',
    'Aspirar 20 ml de soro fisiológico em uma seringa de 20 ml',
    'Elevar membro'
  ];

  final List<String> thirdChecklistTexts = [
    'Solicitar via aérea avançada COM MÁSCARA DE LARÍNGEA ou IOT',
    'Realizou com sucesso a via aérea avançada e Falar em voz alta:',
    'VIA AÉREA AVANÇADA PRONTA',
    '01 ventilação a cada 06 segundos',
    'Manter fonte de oxigênio a 15 l/min',
    'SOLICITAR INÍCIO DE compressões contínuas por dois minutos e 01 ventilação a cada seis segundos',
    'Chegar pulso e analisar o ritmo por no máximo 10 segundos.',
  ];

  // Listas para os três conjuntos de checkboxes
  List<bool> isCheckedList = List.generate(13, (_) => false);
  List<bool> isCheckedListtwo = List.generate(13, (_) => false);
  List<bool> isCheckedListthree = List.generate(7, (_) => false);

  // Definir quais itens não devem ter checkboxes
  final List<int> firstExcludeIndices = [3, 4, 5, 10, 12];
  final List<int> secondExcludeIndices = [0, 6, 8, 9, 10, 11];
  final List<int> thirdExcludeIndices = [1];

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

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
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
          }
        });
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  String getFormattedTime() {
    int minutes = secondsPassed ~/ 60;
    int seconds = secondsPassed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  //Função para gerar e mostrar o relatório
  String generateReport() {
    final StringBuffer report = StringBuffer();

    // Cabeçalho do relatório
    report.writeln('Relatório de Atendimento AESP/Assistolia\n');
    report.writeln('Tempo total: ${getFormattedTime()}');
    report.writeln('Ciclos completados: $cycles');
    report.writeln('Doses de Epinefrina: $epinephrineDoses\n');

    // Primeira iniciais
    report.writeln('Procedimentos iniciais:');
    for (int i = 0; i < firstChecklistTexts.length; i++) {
      if (isCheckedList[i]) {
        report.writeln('✓ ${firstChecklistTexts[i]}');
      }
    }

    // Acesso Venoso e Medicação
    report.writeln('\nAcesso Venoso e Medicação:');
    for (int i = 0; i < secondChecklistTexts.length; i++) {
      if (isCheckedListtwo[i]) {
        report.writeln('✓ ${secondChecklistTexts[i]}');
      }
    }

    // Via Aérea
    report.writeln('\nVia Aérea:');
    for (int i = 0; i < thirdChecklistTexts.length; i++) {
      if (isCheckedListthree[i]) {
        report.writeln('✓ ${thirdChecklistTexts[i]}');
      }
    }

    return report.toString();
  }

  void shareReport() {
    final String reportText = generateReport();
    Share.share(reportText,
        subject: 'Relatório de Atendimento AESP/Assistolia');
  }

  void showReport() {
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
              shareReport();
              Navigator.pop(context);
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _navigateToActionsPage() {
    _navigateToPage(0); // método genérico para navegar para a página principal
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (pageController.page != 0) {
          _navigateToActionsPage();
          return false; // Impede que o app saia ou volte à tela anterior
        }
        return true; // Permite o comportamento normal de voltar
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.aespAssistolia,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis, // Tranca o texto longo
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${getFormattedTime()}  •  Ciclos: $cycles',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
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
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildActionsPage(),
                  _buildFirstChecklistPage(),
                  _buildSecondChecklistPage(),
                  _buildThirdChecklistPage(),
                ],
              ),
            ),
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
        // Cartão de Compressão Torácica com cor de fundo verde quando ativo
        MedicalActionCardAesp(
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
          child: MedicalActionCardAesp(
            title: "Ventilações",
            icon: Icons.air,
            onPressed: () {},
            description:
                "AMBU: 2 ventilações / 30 compressões\nIOT: 10 ventilações/minuto",
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardAesp(
          title: "Epinefrina 1mg",
          icon: Icons.medical_services,
          onPressed: () {
            setState(() => epinephrineDoses++);
          },
          description: "Administrar a cada 3-5 minutos",
          statsWidget: Text(
            'Doses: $epinephrineDoses',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 0),
        MedicalActionCardAesp(
          title: "Gerar Relatório",
          icon: Icons.description,
          onPressed: showReport,
          description: "Visualizar resumo do atendimento",
        ),
      ],
    );
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

  Widget _buildFirstChecklistPage() {
    return _buildChecklistPage(
      firstChecklistTexts,
      isCheckedList,
      firstExcludeIndices,
      'Procedimentos Iniciais',
    );
  }

  Widget _buildSecondChecklistPage() {
    return _buildChecklistPage(
      secondChecklistTexts,
      isCheckedListtwo,
      secondExcludeIndices,
      'Acesso Venoso e Medicação',
    );
  }

  Widget _buildThirdChecklistPage() {
    return _buildChecklistPage(
      thirdChecklistTexts,
      isCheckedListthree,
      thirdExcludeIndices,
      'Via Aérea',
    );
  }

  Widget _buildChecklistPage(
    List<String> items,
    List<bool> checkedList,
    List<int> excludeIndices,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final bool isExcluded = excludeIndices.contains(index);

              // Se o item estiver excluído, renderize um ListTile normal
              if (isExcluded) {
                return ListTile(
                  title: Text(
                    items[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  dense: true,
                );
              }

              // Em vez de usar Card, usar um Container sem decoração
              return CheckboxListTile(
                title: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: checkedList[index]
                        ? FontWeight.normal
                        : FontWeight.normal,
                  ),
                ),
                value: checkedList[index],
                activeColor: Colors.green,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      checkedList[index] = value;
                    });
                  }
                },
                controlAffinity: ListTileControlAffinity.trailing,
                dense: true,
                tileColor: Colors.transparent, // Sem cor de fundo
              );
            },
          ),
        ),
      ],
    );
  }
}
