import 'package:covidfen/models/who_data.dart';
import 'package:covidfen/models/who_topic.dart';
import 'package:json_annotation/json_annotation.dart';

part 'who_advice.g.dart';

@JsonSerializable()
class WHOAdvice {
  final String title;
  final String subtitle;
  final List<WHOData?>? basics;
  final List<WHOTopic?>? topics;

  WHOAdvice({required this.title, required this.subtitle, required this.basics, required this.topics});

  factory WHOAdvice.fromJson(Map<String, dynamic> json) =>
      _$WHOAdviceFromJson(json);
  Map<String, dynamic> toJSON() => _$WHOAdviceToJson(this);
}
