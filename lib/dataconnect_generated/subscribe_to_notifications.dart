part of 'example.dart';

class SubscribeToNotificationsVariablesBuilder {
  String targetIdentifier;
  String type;
  String userId;

  final FirebaseDataConnect _dataConnect;
  SubscribeToNotificationsVariablesBuilder(this._dataConnect, {required  this.targetIdentifier,required  this.type,required  this.userId,});
  Deserializer<SubscribeToNotificationsData> dataDeserializer = (dynamic json)  => SubscribeToNotificationsData.fromJson(jsonDecode(json));
  Serializer<SubscribeToNotificationsVariables> varsSerializer = (SubscribeToNotificationsVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SubscribeToNotificationsData, SubscribeToNotificationsVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SubscribeToNotificationsData, SubscribeToNotificationsVariables> ref() {
    SubscribeToNotificationsVariables vars= SubscribeToNotificationsVariables(targetIdentifier: targetIdentifier,type: type,userId: userId,);
    return _dataConnect.mutation("SubscribeToNotifications", dataDeserializer, varsSerializer, vars);
  }
}

class SubscribeToNotificationsNotificationSubscriptionInsert {
  String id;
  SubscribeToNotificationsNotificationSubscriptionInsert.fromJson(dynamic json):
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SubscribeToNotificationsNotificationSubscriptionInsert({
    required this.id,
  });
}

class SubscribeToNotificationsData {
  SubscribeToNotificationsNotificationSubscriptionInsert notificationSubscription_insert;
  SubscribeToNotificationsData.fromJson(dynamic json):
  notificationSubscription_insert = SubscribeToNotificationsNotificationSubscriptionInsert.fromJson(json['notificationSubscription_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notificationSubscription_insert'] = notificationSubscription_insert.toJson();
    return json;
  }

  SubscribeToNotificationsData({
    required this.notificationSubscription_insert,
  });
}

class SubscribeToNotificationsVariables {
  String targetIdentifier;
  String type;
  String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SubscribeToNotificationsVariables.fromJson(Map<String, dynamic> json):
  targetIdentifier = nativeFromJson<String>(json['targetIdentifier']),type = nativeFromJson<String>(json['type']),userId = nativeFromJson<String>(json['userId']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['targetIdentifier'] = nativeToJson<String>(targetIdentifier);
    json['type'] = nativeToJson<String>(type);
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  SubscribeToNotificationsVariables({
    required this.targetIdentifier,
    required this.type,
    required this.userId,
  });
}

