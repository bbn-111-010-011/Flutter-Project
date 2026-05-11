class Achat {
  final String id;
  final DateTime date;
  final double total;
  final List<dynamic> articles;

  Achat({
    required this.id,
    required this.date,
    required this.total,
    required this.articles,
  });

  factory Achat.fromSupabase(Map<String, dynamic> json) {
    return Achat(
      id: json['id'].toString(),
      date: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      total: double.tryParse(json['total'].toString()) ?? 0,
      articles: json['articles'] is List ? json['articles'] : [],
    );
  }
}
