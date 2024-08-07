class QuoteModel {
  final String? quoteText;
  final String? authorName;
  final String? authorImageUrl;
  final String? characterCount;
  final String? preFormattedHTMLQuote;

  QuoteModel({
    this.quoteText,
    this.authorName,
    this.authorImageUrl,
    this.characterCount,
    this.preFormattedHTMLQuote,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteText: json['q'] as String?,
      authorName: json['a'] as String?,
      authorImageUrl: json['i'] as String?,
      characterCount: json['c'] as String?,
      preFormattedHTMLQuote: json['h'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': quoteText,
      'a': authorName,
      'i': authorImageUrl,
      'c': characterCount,
      'h': preFormattedHTMLQuote,
    };
  }
}
