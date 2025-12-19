class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String imageUrl;
  final String? url; // New field for RSS link

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.imageUrl,
    this.url,
  });
}

// Static data for MVP
final List<Article> kDummyArticles = [
  Article(
    id: '1',
    title: 'Understanding Perimenopause',
    summary: 'What to expect when your hormones start shifting in your 40s.',
    category: 'Education',
    imageUrl: 'https://images.unsplash.com/photo-1544367563-12123d8965cd?auto=format&fit=crop&q=80&w=300',
    content: '''
# Understanding Perimenopause

Perimenopause means "around menopause" and refers to the time during which your body makes the natural transition to menopause, marking the end of the reproductive years.

## Common Symptoms
- Irregular periods
- Hot flashes and sleep problems
- Mood changes
- Vaginal and bladder problems

## Managing Symptoms
Lifestyle changes can help! Focus on a balanced diet, regular exercise, and stress management techniques like yoga or meditation.
    ''',
  ),
  Article(
    id: '2',
    title: 'Nutrition for Hormone Health',
    summary: 'Top foods to eat to support your body during menopause.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&q=80&w=300',
    content: '''
# Nutrition for Hormone Health

What you eat can have a big impact on how you feel.

## Key Nutrients
1. **Calcium & Vitamin D**: Essential for bone health as estrogen drops.
2. **Healthy Fats**: Avocado, nuts, and olive oil support hormone production.
3. **Fiber**: Helps balance blood sugar and manage weight.

## Foods to Limit
Try to reduce caffeine, alcohol, and spicy foods if you suffer from hot flashes.
    ''',
  ),
  Article(
    id: '3',
    title: 'Sleep Better Tonight',
    summary: 'Tips to combat insomnia and night sweats.',
    category: 'Sleep',
    imageUrl: 'https://images.unsplash.com/photo-1541781777265-d18dd2f87a81?auto=format&fit=crop&q=80&w=300',
    content: '''
# Sleep Better Tonight

Sleep disturbances are common during menopause, often due to night sweats or anxiety.

## Tips
- **Cool Bedroom**: Keep the temperature low (around 65°F / 18°C).
- **Cotton Bedding**: Use breathable layers.
- **Routine**: Go to bed at the same time every night.
- **Avoid Screens**: No phones 1 hour before bed.
    ''',
  ),
];
