import 'package:flutter/material.dart';
import '../utils/constants.dart';
import './fv_tvsp_screen.dart';
import './aesp_assistolia_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appTitle, style: AppTextStyles.appBarTitle),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: [ 
          // Botão de informação na AppBar
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showAppInfo(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRoutineButton(
                context,
                AppStrings.fvTvsp,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FvTvspScreen()),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color.fromARGB(255, 0, 0, 0), thickness: 2),
              const SizedBox(height: 16),
              _buildRoutineButton(
                context,
                AppStrings.aespAssistolia,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AespAssistoliaScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _buildInstructionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Mostrar informações do aplicativo
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sobre o Aplicativo', 
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Desenvolvido por: Thiago Resmini Slongo'),
                SizedBox(height: 8),
                Text('Colaboradores do Projeto: Jhoanna Vitória, Luan Carlos, Eduardo de Souza e Renato Scortegagna'),
                SizedBox(height: 8),
                Text('Versão: 1.0.0'),
                SizedBox(height: 8),
                Text('Este aplicativo foi criado para auxiliar os estudantes para a prática de RCP.'),
                SizedBox(height: 12),
                Text('© 2025 - Todos os direitos reservados'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoutineButton(BuildContext context, String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(title, style: AppTextStyles.buttonText),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.instructionsTitle, style: AppTextStyles.instructionsTitle),
          SizedBox(height: 12),
          Text(AppStrings.instructionsText, style: AppTextStyles.instructionsBody),
          SizedBox(height: 12),
          Text(AppStrings.instructionsSteps, style: AppTextStyles.instructionsBody),
        ],
      ),
    );
  }
}