import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_unescape/html_unescape.dart';
import 'article_data.dart';

final educationRepositoryProvider = Provider((ref) => EducationRepository());

final rssArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final repo = ref.watch(educationRepositoryProvider);
  return repo.fetchArticles();
});

class EducationRepository {
  final _unescape = HtmlUnescape();

  // Feed URLs - Mix of Medical and Lifestyle/Blog
  static const List<String> _feedUrls = [
    'https://www.sciencedaily.com/rss/health_medicine/menopause.xml',
    'https://www.sciencedaily.com/rss/health_medicine/womens_health.xml',
    'https://redhotmamas.org/feed/', 
    'https://menopausegoddessblog.com/feed/',
    'https://www.womenshealthmag.com/rss/health.xml', 
  ];

  Future<List<Article>> fetchArticles() async {
    try {
      // Fetch all feeds in parallel
      final futures = _feedUrls.map((url) => _fetchAndParse(url));
      final results = await Future.wait(futures);
      
      // Flatten list
      final allArticles = results.expand((x) => x).toList();
      
      // Deduplicate by title
      final uniqueArticles = <String, Article>{};
      for (var article in allArticles) {
        // Cleaning title to match better
        uniqueArticles[article.title.trim()] = article;
      }
      
      final distinctList = uniqueArticles.values.toList();

      // STRICT FILTER: apply to everything
      final filtered = distinctList.where((a) => _isRelevant(a)).toList();
      
      return filtered.take(20).toList();

    } catch (e) {
      print('Error fetching RSS: $e');
      return kDummyArticles;
    }
  }

  Future<List<Article>> _fetchAndParse(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return [];

      // Force UTF-8 decoding. response.body often guesses Latin-1 for RSS.
      final xmlString = utf8.decode(response.bodyBytes);
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      return items.map((node) {
        final rawTitle = node.findElements('title').singleOrNull?.innerText ?? 'No Title';
        final title = _unescape.convert(rawTitle); // Decode
        
        final link = node.findElements('link').singleOrNull?.innerText.trim() ?? '';
        
        // Handle Content/Description variations
        String rawDescription = node.findElements('description').singleOrNull?.innerText ?? '';
        final contentEncoded = node.findElements('content:encoded').singleOrNull?.innerText;
        if (contentEncoded != null && contentEncoded.length > rawDescription.length) {
            rawDescription = contentEncoded;
        }
        
        // Decode description but keep HTML logic for image extraction separate if needed
        // Actually, regex works best on raw HTML. We should unescape AFTER extracting image and stripping tags.
        
        // 1. Extract Image from RAW description
        String imageUrl = 'https://images.unsplash.com/photo-1516585427167-9f4af9627e6c?auto=format&fit=crop&q=80&w=300';
        // ... (reuse existing image logic, passing node and rawDescription)
        
        // Image logic needs to be inside the map. I'll copy the block from previous step but use rawDescription.
        
        // 1. Check media:content
        final mediaContent = node.findElements('media:content').firstOrNull;
        if (mediaContent != null) {
          final url = mediaContent.getAttribute('url');
          if (url != null && url.isNotEmpty) imageUrl = url;
        }
        // 2-4 fallback logic... (omitted for brevity in replacement, but I must providing full replacement content)
        // I will just use the standard image logic here.
        
        if (imageUrl.contains('unsplash')) {
             final mediaThumb = node.findElements('media:thumbnail').firstOrNull;
             if (mediaThumb != null) {
               final url = mediaThumb.getAttribute('url');
               if (url != null && url.isNotEmpty) imageUrl = url;
             }
        }
        if (imageUrl.contains('unsplash')) {
             final enclosure = node.findElements('enclosure').firstOrNull;
             if (enclosure != null && (enclosure.getAttribute('type')?.startsWith('image') ?? false)) {
                final url = enclosure.getAttribute('url');
                if (url != null && url.isNotEmpty) imageUrl = url;
             }
        }
        if (imageUrl.contains('unsplash')) {
          final imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');
          final match = imgRegExp.firstMatch(rawDescription);
          if (match != null) {
            imageUrl = match.group(1) ?? imageUrl;
          }
        }

        // Clean description
        final cleanDesc = _cleanDescription(rawDescription); // Removes tags
        final decodedDesc = _unescape.convert(cleanDesc); // Decodes &amp; etc

        final guid = node.findElements('guid').singleOrNull?.innerText ?? link;

        return Article(
          id: guid,
          title: title,
          summary: decodedDesc,
          content: rawDescription, // Keep raw for webview or other uses? Or just decoded.
          category: _determineCategory(url),
          imageUrl: imageUrl,
          url: link,
        );
      }).toList();
    } catch (e) {
      print('Parse error for $url: $e');
      return [];
    }
  }
  
  String _determineCategory(String url) {
    if (url.contains('sciencedaily')) return 'Medical News';
    if (url.contains('redhotmamas')) return 'Expert Blog';
    if (url.contains('menopausegoddess')) return 'Community';
    return 'Health';
  }

  bool _isRelevant(Article article) {
    print('Checking relevance for: ${article.title}'); 
    // Strict keyword filtering to ensure top relevance
    final text = '${article.title} ${article.summary}'.toLowerCase();
    final keywords = [
      'period', 'menstruation', 'menopause', 'hormone', 'estrogen', 
      'ovary', 'uterus', 'pms', 'cycle', 'reproductive', 'vaginal',
      'fertility', 'pregnancy', 'maternal', 'breast', 'cervical',
      'hot flash', 'night sweat', 'cramps', 'bleeding', 'endo', 'pcos'
    ];
    
    // Check if any keyword corresponds
    return keywords.any((k) => text.contains(k));
  }
  
  String _cleanDescription(String raw) {
    // Remove HTML tags
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
