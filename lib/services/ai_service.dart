import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // You can plug in your API key here (e.g., OpenRouter or Google Gemini API key)
  // For client handoff, they can replace this string with their own API key.
  static const String apiKey = "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"; 
  
  static Future<String> getEcoAiAdvice(int percentage, String temperature, String airflow) async {
    if (apiKey == "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" || apiKey.isEmpty) {
      // Fallback smart simulation response if no API key is provided yet
      return "AI Diagnostic: Based on your exhaust temp of $temperature and filter condition at $percentage%, "
             "combustion is currently stable. However, urban stop-and-go driving will accelerate carbon buildup. "
             "Recommended action: Flush the exhaust mesh within the next 50 kilometers to preserve fuel efficiency.";
    }

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "recursive/flint-v1.0:free",
          "messages": [
            {
              "role": "system",
              "content": "You are REFIT AI, an expert eco-mechanical assistant for tricycle exhaust and carbon emission monitoring systems."
            },
            {
              "role": "user",
              "content": "Analyze these tricycle sensor stats: Filter Condition: $percentage%, Temperature: $temperature, Airflow: $airflow. Give a short, practical maintenance and carbon-reduction recommendation for the rider."
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Unable to reach AI server right now. Check your network connection.";
      }
    } catch (e) {
      return "AI Connection Error: Please verify your internet or API configuration.";
    }
  }
}