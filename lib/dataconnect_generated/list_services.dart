part of 'example.dart';

class ListServicesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListServicesVariablesBuilder(this._dataConnect, );
  Deserializer<ListServicesData> dataDeserializer = (dynamic json)  => ListServicesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListServicesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListServicesData, void> ref() {
    
    return _dataConnect.query("ListServices", dataDeserializer, emptySerializer, null);
  }
}

class ListServicesServices {
  String id;
  String name;
  String description;
  String? contactInfo;
  String? onlineLink;
  String? requirements;
  ListServicesServices.fromJson(dynamic json):
  id = nativeFromJson<String>(json['id']),name = nativeFromJson<String>(json['name']),description = nativeFromJson<String>(json['description']),contactInfo = json['contactInfo'] == null ? null : nativeFromJson<String>(json['contactInfo']),onlineLink = json['onlineLink'] == null ? null : nativeFromJson<String>(json['onlineLink']),requirements = json['requirements'] == null ? null : nativeFromJson<String>(json['requirements']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['description'] = nativeToJson<String>(description);
    if (contactInfo != null) {
      json['contactInfo'] = nativeToJson<String?>(contactInfo);
    }
    if (onlineLink != null) {
      json['onlineLink'] = nativeToJson<String?>(onlineLink);
    }
    if (requirements != null) {
      json['requirements'] = nativeToJson<String?>(requirements);
    }
    return json;
  }

  ListServicesServices({
    required this.id,
    required this.name,
    required this.description,
    this.contactInfo,
    this.onlineLink,
    this.requirements,
  });
}

class ListServicesData {
  List<ListServicesServices> services;
  ListServicesData.fromJson(dynamic json):
  services = (json['services'] as List<dynamic>)
        .map((e) => ListServicesServices.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['services'] = services.map((e) => e.toJson()).toList();
    return json;
  }

  ListServicesData({
    required this.services,
  });
}

