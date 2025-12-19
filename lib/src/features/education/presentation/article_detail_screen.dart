import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../data/article_data.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(article.title, style: const TextStyle(fontSize: 16)), // Small title when collapsed
              background: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.3), // Darken for text readability
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  article.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                MarkdownBody(data: article.content),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
