import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

void main() async {
  final urls = [
    'https://www.sciencedaily.com/rss/health_medicine/menopause.xml',
    'https://www.sciencedaily.com/rss/health_medicine/womens_health.xml',
    'https://redhotmamas.org/feed/', 
    'https://menopausegoddessblog.com/feed/',
  ];

  for (final url in urls) {
    print('\nFetching $url...');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        print('✅ Success: Found ${items.length} items.');
        
        if (items.isNotEmpty) {
            final firstLink = items.first.findElements('link').singleOrNull?.innerText;
            print('Sample Link (Raw): "$firstLink"');
            
            if (firstLink != null) {
                 final trimmed = firstLink.trim();
                 print('Sample Link (Trimmed): "$trimmed"');
                 // Check whitespace chars
                 print('Code units: ${trimmed.codeUnits}');
            }
        }
      } else {
        print('❌ Failed status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
