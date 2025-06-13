// @dart=2.9

import 'reward.dart';

class HistoryRewardModel {
  String id;
  String createdAt;
  String updatedAt;
  RewardModel reward;
  int status;

  HistoryRewardModel(
      {this.id, this.createdAt, this.updatedAt, this.reward, this.status});

  factory HistoryRewardModel.fromJson(dynamic json) {
    return HistoryRewardModel(
        id: json['_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        reward: RewardModel.fromJson(json['reward']),
        status: json['status']);
  }
}
