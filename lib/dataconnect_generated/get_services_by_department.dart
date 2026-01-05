part of 'example.dart';

class GetServicesByDepartmentVariablesBuilder {
  String departmentId;

  final FirebaseDataConnect _dataConnect;
  GetServicesByDepartmentVariablesBuilder(this._dataConnect, {required  this.departmentId,});
  Deserializer<GetServicesByDepartmentData> dataDeserializer = (dynamic json)  => GetServicesByDepartmentData.fromJson(jsonDecode(json));
  Serializer<GetServicesByDepartmentVariables> varsSerializer = (GetServicesByDepartmentVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetServicesByDepartmentData, GetServicesByDepartmentVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetServicesByDepartmentData, GetServicesByDepartmentVariables> ref() {
    GetServicesByDepartmentVariables vars= GetServicesByDepartmentVariables(departmentId: departmentId,);
    return _dataConnect.query("GetServicesByDepartment", dataDeserializer, varsSerializer, vars);
  }
}

class GetServicesByDepartmentServices {
  String id;
  String name;
  String description;
  String? contactInfo;
  String? onlineLink;
  String? requirements;
  GetServicesByDepartmentServices.fromJson(dynamic json):
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

  GetServicesByDepartmentServices({
    required this.id,
    required this.name,
    required this.description,
    this.contactInfo,
    this.onlineLink,
    this.requirements,
  });
}

class GetServicesByDepartmentData {
  List<GetServicesByDepartmentServices> services;
  GetServicesByDepartmentData.fromJson(dynamic json):
  services = (json['services'] as List<dynamic>)
        .map((e) => GetServicesByDepartmentServices.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['services'] = services.map((e) => e.toJson()).toList();
    return json;
  }

  GetServicesByDepartmentData({
    required this.services,
  });
}

class GetServicesByDepartmentVariables {
  String departmentId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetServicesByDepartmentVariables.fromJson(Map<String, dynamic> json):
  departmentId = nativeFromJson<String>(json['departmentId']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['departmentId'] = nativeToJson<String>(departmentId);
    return json;
  }

  GetServicesByDepartmentVariables({
    required this.departmentId,
  });
}

