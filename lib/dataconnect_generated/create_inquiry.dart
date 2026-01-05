part of 'example.dart';

class CreateInquiryVariablesBuilder {
  String departmentId;
  String userId;
  String message;
  String status;
  String subject;

  final FirebaseDataConnect _dataConnect;
  CreateInquiryVariablesBuilder(this._dataConnect, {required  this.departmentId,required  this.userId,required  this.message,required  this.status,required  this.subject,});
  Deserializer<CreateInquiryData> dataDeserializer = (dynamic json)  => CreateInquiryData.fromJson(jsonDecode(json));
  Serializer<CreateInquiryVariables> varsSerializer = (CreateInquiryVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateInquiryData, CreateInquiryVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateInquiryData, CreateInquiryVariables> ref() {
    CreateInquiryVariables vars= CreateInquiryVariables(departmentId: departmentId,userId: userId,message: message,status: status,subject: subject,);
    return _dataConnect.mutation("CreateInquiry", dataDeserializer, varsSerializer, vars);
  }
}

class CreateInquiryInquiryInsert {
  String id;
  CreateInquiryInquiryInsert.fromJson(dynamic json):
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateInquiryInquiryInsert({
    required this.id,
  });
}

class CreateInquiryData {
  CreateInquiryInquiryInsert inquiry_insert;
  CreateInquiryData.fromJson(dynamic json):
  inquiry_insert = CreateInquiryInquiryInsert.fromJson(json['inquiry_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['inquiry_insert'] = inquiry_insert.toJson();
    return json;
  }

  CreateInquiryData({
    required this.inquiry_insert,
  });
}

class CreateInquiryVariables {
  String departmentId;
  String userId;
  String message;
  String status;
  String subject;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateInquiryVariables.fromJson(Map<String, dynamic> json):
  departmentId = nativeFromJson<String>(json['departmentId']),userId = nativeFromJson<String>(json['userId']),message = nativeFromJson<String>(json['message']),status = nativeFromJson<String>(json['status']),subject = nativeFromJson<String>(json['subject']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['departmentId'] = nativeToJson<String>(departmentId);
    json['userId'] = nativeToJson<String>(userId);
    json['message'] = nativeToJson<String>(message);
    json['status'] = nativeToJson<String>(status);
    json['subject'] = nativeToJson<String>(subject);
    return json;
  }

  CreateInquiryVariables({
    required this.departmentId,
    required this.userId,
    required this.message,
    required this.status,
    required this.subject,
  });
}

