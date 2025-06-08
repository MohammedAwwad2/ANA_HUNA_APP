import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyAymb7h68s42zt6xY7jmJMBUjqPiMyU27M';
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> generateText(String prompt,
      {bool isCorrection = true, bool withAnswer = false}) async {
    final cleanedPrompt = prompt.trim();

    if (cleanedPrompt.split(' ').length == 1) {
      return cleanedPrompt;
    }

    final String systemPrompt = isCorrection
        ? '''
      أنت مدقق لغوي محترف في اللغة العربية.

      مهمتك: تصحيح الجمل المدخلة وتحسينها لغوياً.

      اتبع التعليمات التالية بدقة:
      1. تأكد من صحة التركيب النحوي للجملة.
      2. قم بالتصحيح كما يلي:
         - دمج الحروف والكلمات المفصولة لتشكيل كلمات صحيحة.
         - تصحيح الأخطاء النحوية (التذكير، التأنيث، ترتيب الكلمات).
         - الحفاظ على المعنى الأصلي.
         - إضافة حروف الجر المناسبة عند الحاجة.
         -ضع علامات تعجب و علامات استفهام فقط عند الحاجة. 
      3. قدم النص المصحح مباشرة دون أي تعليقات إضافية.

      النص:
'''
        : withAnswer
            ? '''
      أنت مساعد ذكي يجيب على الأسئلة باللغة العربية.

      القواعد المهمة:
      1. اكتب الإجابة فقط دون السؤال.
      2. لا تكتب مقدمات مثل "الإجابة هي" أو "الجواب هو".
      3. لا تضع نقاط أو ترقيم في بداية الإجابة.
      4. اجعل الإجابة مباشرة ومختصرة.
      5. لا تضف أي شروحات أو تفاصيل إضافية.
      6. لا تكرر السؤال في الإجابة.
      7. لا تستخدم صيغة السؤال في الإجابة.

      مثال:
      السؤال: ما عاصمة فرنسا؟
      الإجابة المطلوبة: باريس
      (وليس: عاصمة فرنسا هي باريس)

      النص المدخل:
'''
            : '''
      اتبع التعليمات التالية:

      1. قم بتحويل النص إلى سؤال باللغة العربية.
      2. تأكد من صياغة السؤال بشكل واضح ومفهوم.
      3. قدم السؤال مباشرة دون أي مقدمات أو تعليقات.
''';

    final textToSend = '$systemPrompt\n\n$prompt';

    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": textToSend},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.2,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 1000,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text.trim();
    }

    return "عذراً، حدث خطأ في معالجة الطلب"; 
  }
}
