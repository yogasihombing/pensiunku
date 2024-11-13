import 'package:pensiunku/model/faq_model.dart';

class FaqCategoryModel {
  final String name;
  final int order;
  final List<FaqModel> faqs;

  FaqCategoryModel({
    required this.name,
    required this.order,
    this.faqs = const [],
  });

  factory FaqCategoryModel.fromJson(
    Map<String, dynamic> json,
    List<dynamic> faqsJson,
  ) {
    List<FaqModel> faqs = [];
    faqsJson.asMap().forEach((index, faqJson) {
      faqs.add(FaqModel.fromJson({
        ...faqJson,
        'item_order': index + 1,
      }));
    });
    return FaqCategoryModel(
      name: json['name'],
      order: json['item_order'],
      faqs: faqs,
    );
  }

  Map<String, dynamic> toJson(int newOrder) {
    return {
      'name': name,
      'item_order': newOrder,
    };
  }
}
