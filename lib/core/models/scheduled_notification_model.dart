import 'dart:convert';
import 'package:flutter/material.dart';

class ScheduledNotificationModel {
  final int id;
  final String rewardId;
  final String title;
  final String body;
  final TimeOfDay time;

  ScheduledNotificationModel({
    required this.id,
    required this.rewardId,
    required this.title,
    required this.body,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rewardId': rewardId,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  factory ScheduledNotificationModel.fromMap(Map<String, dynamic> map) {
    return ScheduledNotificationModel(
      id: map['id'],
      rewardId: map['rewardId'],
      title: map['title'],
      body: map['body'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduledNotificationModel.fromJson(String source) =>
      ScheduledNotificationModel.fromMap(json.decode(source));
}
