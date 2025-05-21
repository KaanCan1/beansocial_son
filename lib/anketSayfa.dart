import 'dart:math';

import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';

enum QuestionType {
  multipleChoice,
  yesNo,
  scale,
}

class SurveyQuestion {
  final String question;
  final QuestionType type;
  final List<String>? options;

  SurveyQuestion({
    required this.question,
    required this.type,
    this.options,
  });
}

class CoffeeSurveyPage extends StatefulWidget {
  const CoffeeSurveyPage({super.key});

  @override
  _CoffeeSurveyPageState createState() => _CoffeeSurveyPageState();
}

class _CoffeeSurveyPageState extends State<CoffeeSurveyPage> {
  final List<SurveyQuestion> allQuestions = [
    SurveyQuestion(
      question: "Yumuşak içim kahve sever misiniz?",
      type: QuestionType.yesNo,
    ),
    SurveyQuestion(
      question: "Sütlü kahveleri tercih eder misiniz?",
      type: QuestionType.yesNo,
    ),
    SurveyQuestion(
      question: "Kahvede asidite tercihinizi 1-10 arasında belirtiniz.",
      type: QuestionType.scale,
    ),
    SurveyQuestion(
      question: "Hangi kahve türünü daha çok tercih edersiniz?",
      type: QuestionType.multipleChoice,
      options: ["Espresso", "Latte", "Filtre Kahve", "Türk Kahvesi"],
    ),
    // Daha fazla soru eklenecek...
  ];

  final List<String> coffeeTips = [
    "☕ Arabica çekirdekleri genellikle daha tatlı ve yumuşaktır.",
    "🌍 Kahve ilk olarak Etiyopya'da keşfedildi!",
    "🔥 Koyu kavurma kahveler, daha az kafein içerir.",
    "🥛 Süt, kahvenin asiditesini dengeler.",
    "⏳ French Press demleme, kahvenin gövdesini artırır.",
    "🌿 Filtre kahveler, espressoya göre daha fazla antioksidan içerir.",
    "🫘 Taze öğütülmüş kahve, her zaman daha aromatiktir.",
    "❄️ Cold Brew kahve, yaz günlerinin kahramanıdır.",
    "🇹🇷 Türk kahvesi UNESCO kültürel miras listesinde yer alır!",
    "📈 Kahve tüketimi, yaratıcı düşünceyi destekler.",
  ];

  late List<SurveyQuestion> selectedQuestions;
  final Map<int, dynamic> answers = {};

  @override
  void initState() {
    super.initState();
    selectedQuestions = _generateRandomQuestions();
  }

  List<SurveyQuestion> _generateRandomQuestions() {
    final random = Random();
    final shuffled = [...allQuestions]..shuffle(random);
    return shuffled.take(10).toList();
  }

  String _getRandomTip(int index) {
    return coffeeTips[index % coffeeTips.length];
  }

  void _submitSurvey() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Teşekkürler!"),
        content: const Text("Cevaplarınız kaydedildi ☕"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/AnaSayfa',
                  (route) => false,
                );
              });
            },
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, SurveyQuestion question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      color: Colors.brown[50],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Soru ${index + 1}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 16),
            if (question.type == QuestionType.multipleChoice &&
                question.options != null)
              ...question.options!.map((opt) => RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: answers[index],
                    activeColor: Colors.brown[400],
                    onChanged: (val) => setState(() => answers[index] = val),
                  )),
            if (question.type == QuestionType.yesNo)
              Row(
                children: ["Evet", "Hayır"].map((opt) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: answers[index],
                      activeColor: Colors.brown[400],
                      onChanged: (val) => setState(() => answers[index] = val),
                    ),
                  );
                }).toList(),
              ),
            if (question.type == QuestionType.scale)
              Column(
                children: [
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: (answers[index] ?? 5).toDouble(),
                    label: "${answers[index] ?? 5}",
                    onChanged: (val) =>
                        setState(() => answers[index] = val.round()),
                    activeColor: Colors.brown[300],
                  ),
                  Text("Seçilen seviye: ${answers[index] ?? 5}"),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_cafe, size: 20, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRandomTip(index),
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 300, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Kahve Tercih Anketi",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...selectedQuestions.asMap().entries.map(
                      (entry) => _buildQuestionCard(entry.key, entry.value)),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _submitSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      "Anketi Gönder",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Footerr(children: []),
          ],
        ),
      ),
    );
  }
}
