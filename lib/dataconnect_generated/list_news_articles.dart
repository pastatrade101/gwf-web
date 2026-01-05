part of 'example.dart';

class ListNewsArticlesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListNewsArticlesVariablesBuilder(this._dataConnect, );
  Deserializer<ListNewsArticlesData> dataDeserializer = (dynamic json)  => ListNewsArticlesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListNewsArticlesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListNewsArticlesData, void> ref() {
    
    return _dataConnect.query("ListNewsArticles", dataDeserializer, emptySerializer, null);
  }
}

class ListNewsArticlesNewsArticles {
  String id;
  String title;
  String content;
  Timestamp publishedAt;
  String? author;
  String? imageUrl;
  String category;
  String? region;
  String? council;
  ListNewsArticlesNewsArticles.fromJson(dynamic json):
  id = nativeFromJson<String>(json['id']),title = nativeFromJson<String>(json['title']),content = nativeFromJson<String>(json['content']),publishedAt = Timestamp.fromJson(json['publishedAt']),author = json['author'] == null ? null : nativeFromJson<String>(json['author']),imageUrl = json['imageUrl'] == null ? null : nativeFromJson<String>(json['imageUrl']),category = nativeFromJson<String>(json['category']),region = json['region'] == null ? null : nativeFromJson<String>(json['region']),council = json['council'] == null ? null : nativeFromJson<String>(json['council']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['content'] = nativeToJson<String>(content);
    json['publishedAt'] = publishedAt.toJson();
    if (author != null) {
      json['author'] = nativeToJson<String?>(author);
    }
    if (imageUrl != null) {
      json['imageUrl'] = nativeToJson<String?>(imageUrl);
    }
    json['category'] = nativeToJson<String>(category);
    if (region != null) {
      json['region'] = nativeToJson<String?>(region);
    }
    if (council != null) {
      json['council'] = nativeToJson<String?>(council);
    }
    return json;
  }

  ListNewsArticlesNewsArticles({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.author,
    this.imageUrl,
    required this.category,
    this.region,
    this.council,
  });
}

class ListNewsArticlesData {
  List<ListNewsArticlesNewsArticles> newsArticles;
  ListNewsArticlesData.fromJson(dynamic json):
  newsArticles = (json['newsArticles'] as List<dynamic>)
        .map((e) => ListNewsArticlesNewsArticles.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['newsArticles'] = newsArticles.map((e) => e.toJson()).toList();
    return json;
  }

  ListNewsArticlesData({
    required this.newsArticles,
  });
}
