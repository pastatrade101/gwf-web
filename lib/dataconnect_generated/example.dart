library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'create_inquiry.dart';

part 'list_news_articles.dart';

part 'subscribe_to_notifications.dart';

part 'get_services_by_department.dart';

part 'list_services.dart';







class ExampleConnector {
  
  
  CreateInquiryVariablesBuilder createInquiry ({required String departmentId, required String userId, required String message, required String status, required String subject, }) {
    return CreateInquiryVariablesBuilder(dataConnect, departmentId: departmentId,userId: userId,message: message,status: status,subject: subject,);
  }
  
  
  ListNewsArticlesVariablesBuilder listNewsArticles () {
    return ListNewsArticlesVariablesBuilder(dataConnect, );
  }
  
  
  SubscribeToNotificationsVariablesBuilder subscribeToNotifications ({required String targetIdentifier, required String type, required String userId, }) {
    return SubscribeToNotificationsVariablesBuilder(dataConnect, targetIdentifier: targetIdentifier,type: type,userId: userId,);
  }
  
  
  GetServicesByDepartmentVariablesBuilder getServicesByDepartment ({required String departmentId, }) {
    return GetServicesByDepartmentVariablesBuilder(dataConnect, departmentId: departmentId,);
  }
  
  
  ListServicesVariablesBuilder listServices () {
    return ListServicesVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'gwf-web-prod',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

