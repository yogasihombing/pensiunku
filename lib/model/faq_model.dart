class FaqModel {
  final String question;
  final String answer;
  final int order;

  FaqModel({
    required this.question,
    required this.answer,
    required this.order,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      question: json['pertanyaan'],
      answer: json['jawaban'],
      order: json['item_order'],
    );
  }

  Map<String, dynamic> toJson(String categoryName, int newOrder) {
    return {
      'kategori_faq': categoryName,
      'pertanyaan': question,
      'jawaban': answer,
      'item_order': newOrder,
    };
  }
}
