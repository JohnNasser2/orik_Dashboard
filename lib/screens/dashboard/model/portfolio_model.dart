import 'dart:convert';
import 'dart:developer';

class PortfolioModel {
  final List<Data> data;
  final String message;
  final bool status;
  List<String> subservice = [];

  PortfolioModel({required this.data, required this.message, required this.status});

  // إضافة قيمة إلى subservice إذا كانت غير موجودة
  void ezzat(String? value) {
    if (value != null && !subservice.contains(value)) {
      if (subservice.isEmpty) {
        subservice.add('All');
      }
      subservice.add(value);
    }
  }

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final model = PortfolioModel(
      data: List<Data>.from(json['data'].map((item) => Data.fromJson(item))),
      message: json['message'],
      status: json['status'],
    );

    log(model.data.length.toString(), name: "Data Length");

    // إضافة الـ subservice من كل item داخل data
    for (var i = 0; i < model.data.length; i++) {
      model.ezzat(model.data[i].subservice);
      log('Subservice for item $i: ${model.data[i].subservice}');
    }

    log('Subservice list: ${model.subservice}');
    return model;
  }
}

class Data {
  final String ?cover;
  final List<Content>? content;
  final String? description;
  final int? id;
  final int? isMost;
  final String? subservice;
  final String? title;
  final String? type;

  Data({
    required this.cover,
    required this.content,
    required this.description,
    required this.id,
    required this.isMost,
    this.subservice,
    required this.title,
    required this.type,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    log(json['cover'].toString().replaceFirst('http://', 'https://'), name: "Cover URL");

    // تأكد من أن محتوى الـ data يتم تحليله بشكل صحيح إذا كان هو JSON
    List<Content> contentList = [];
    try {
      if (json['data'] is String) {
        contentList = List<Content>.from(jsonDecode(json['data']).map((item) => Content.fromJson(item)));
      } else if (json['data'] is List) {
        contentList = List<Content>.from(json['data'].map((item) => Content.fromJson(item)));
      }
    } catch (e) {
      log('Error parsing content data: $e', name: "Content Error");
    }

    return Data(
      cover: json['cover'].toString().replaceFirst('http://', 'https://'),
      content: contentList.isNotEmpty ? contentList : null,
      description: json['description'],
      id: json['id'],
      isMost: json['isMost'],
      subservice: json['subservice'],
      title: json['title'],
      type: json['type'],
    );
  }
}

class Content {
  final String type;
  final String value;

  Content({required this.type, required this.value});

  factory Content.fromJson(Map<String, dynamic> json) {
    log(json['value'].toString().replaceFirst('http://', 'https://'), name: "Content URL");

    return Content(
      type: json['type'],
      value: json['value'].toString().replaceFirst('http://', 'https://'),
    );
  }
}
