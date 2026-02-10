import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyDo0osSJkCfGflmLimxPpIbiNuXakabTWw';
  
  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  static Future<List<ParsedIngredient>> parseReceiptImage(
    File imageFile, 
    List<Map<String, dynamic>> pantryIngredients,
  ) async {
    final imageBytes = await imageFile.readAsBytes();
    final imagePart = DataPart('image/jpeg', imageBytes);

    String pantryContext = '';
    if (pantryIngredients.isNotEmpty) {
      pantryContext = '''

IMPORTANT - El meu rebost té aquests ingredients amb les seves UNITATS PREFERIDES:
${pantryIngredients.map((i) => '- ${i['name']}: ${i['unit']}').join('\n')}

Quan detectis un ingredient que coincideixi (o sigui similar), CONVERTEIX a la unitat del rebost:
- Si "pasta" està en "kg" i compro "2 paquets pasta", interpreta ~1kg (2x500g)
- Si "pastanagues" està en "unitats" i compro "1kg pastanagues", interpreta ~10 unitats (~100g/u)
- Si "llet" està en "l" i compro "6 brics", interpreta 6l
- Si "ous" està en "unitats" i compro "1 dotzena", interpreta 12 unitats
- Usa el teu coneixement dels pesos/mides típics dels productes
''';
    }

    final prompt = TextPart('''
Analitza aquest ticket de compra i extreu els productes.

CLASSIFICACIÓ:
- INCLOU: Aliments i ingredients de cuina (carn, peix, verdures, lactis, begudes, condiments, etc.)
- EXCLOU: Neteja, higiene, bosses, taxes, descomptes, tabac, medicines

SIMPLIFICA NOMS:
- Elimina marques (Pascual, Hacendado, Carbonell...)
- Elimina descripcions (EXTRA, PREMIUM, PACK...)
- Tradueix a CATALÀ
- Exemples: "LECHE PASCUAL 1L" → "llet", "ACEITE OLIVA CARBONELL" → "oli d'oliva"
$pantryContext
Per cada producte retorna:
- name: nom genèric en català, minúscules
- quantity: quantitat numèrica
- unit: "g", "kg", "ml", "l" o "unitats"
- uncertain: true si NO ESTÀS SEGUR que sigui un ingredient de cuina o tens dubtes sobre què és
- original: text original del ticket (només si uncertain=true)
- question: pregunta curta per l'usuari (només si uncertain=true)

EXEMPLES D'INCERTESA:
- "FAIRY" → uncertain: true, question: "Fairy és un producte de neteja, l'excloc?"
- "BIFIDUS ACT" → uncertain: true, question: "Això és un iogurt o un suplement?"
- "PREMIUM LINE" → uncertain: true, question: "No puc identificar aquest producte, què és?"

JSON FORMAT:
{
  "ingredients": [
    {"name": "pasta", "quantity": 1, "unit": "kg", "uncertain": false},
    {"name": "desconegut", "quantity": 1, "unit": "unitats", "uncertain": true, "original": "BIFIDUS ACT", "question": "Això és un iogurt o un suplement?"}
  ]
}

Si no pots llegir el ticket: {"ingredients": []}
''');

    try {
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text;
      if (text == null) return [];

      final jsonStr = _extractJson(text);
      final json = jsonDecode(jsonStr);
      final ingredients = (json['ingredients'] as List)
          .map((e) => ParsedIngredient.fromJson(e))
          .toList();
      
      return ingredients;
    } catch (e) {
      throw Exception('Error processant el ticket: $e');
    }
  }

  static String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) return '{"ingredients": []}';
    return text.substring(start, end + 1);
  }
}

class ParsedIngredient {
  String name;
  double quantity;
  String unit;
  bool selected;
  String? linkedIngredientId;
  String? linkedIngredientName;
  bool uncertain;
  String? originalText;
  String? question;

  ParsedIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.selected = true,
    this.linkedIngredientId,
    this.linkedIngredientName,
    this.uncertain = false,
    this.originalText,
    this.question,
  });

  factory ParsedIngredient.fromJson(Map<String, dynamic> json) {
    return ParsedIngredient(
      name: (json['name'] as String).toLowerCase().trim(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'unitats',
      uncertain: json['uncertain'] as bool? ?? false,
      originalText: json['original'] as String?,
      question: json['question'] as String?,
    );
  }

  bool get isLinked => linkedIngredientId != null;
}
