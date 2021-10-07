import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import './article.dart';

enum StoriesType { topStories, newStories }

class HackerNewsBloc {
  List<int> _newIds = [
    28783717,
    28783709,
    28783684,
    28783680,
    28783679,
    28783672,
    28783664,
    28783663,
    28783634,
    28783626,
    28783609,
    28783608,
    28783602,
    28783596,
    28783590,
    28783581,
    28783572,
    28783565,
    28783540,
    28783531,
    28783528,
    28783517,
    28783516,
    28783515
  ];
  List<int> _topIds = [
    28782493,
    28783381,
    28781518,
    28770907,
    28779729,
    28779621,
    28776960,
    28780494,
    28783096,
    28776786,
    28780335,
    28777329,
    28777997,
    28781583,
    28779566,
    28776548,
    28780433,
    28769338,
    28775313,
    28770637,
    28779057,
    28770590,
    28780626,
    28774782,
    28779342
  ];

  var _articles = <Article>[];

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  final _storiesTypeController = StreamController<StoriesType>();
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _isLoadingSubject.stream;

  HackerNewsBloc() {
    // _getNewId();
    // _getTopId();
    _getArticlesAndUpdate(List<int> ids) {
      _updateArticles(ids).then((_) {
        _articlesSubject.add(UnmodifiableListView(_articles));
      });
    }

    _storiesTypeController.stream.listen((storiesType) {
      switch (storiesType) {
        case StoriesType.newStories:
          print('storiesType changed: new stories');
          _getArticlesAndUpdate(_newIds);
          break;
        case StoriesType.topStories:
          print('storiesType changed: top stories');
          _getArticlesAndUpdate(_topIds);
          break;
      }
    });

    _getArticlesAndUpdate(_newIds);
  }

  Future<Null> _updateArticles(List<int> articleIds) async {
    _isLoadingSubject.add(true);
    print('isLoadingstate: ${_isLoadingSubject.value}');
    _articles = await Future.wait(articleIds.map((id) => _getArticle(id)));
    _isLoadingSubject.add(false);
    print('isLoadingstate: ${_isLoadingSubject.value}');
  }

  Future _getNewId() async {
    final articleUrl =
        'https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty';
    final res = await http.get(articleUrl);
    if (res.statusCode == 200) {
      List<int> jobject = jsonDecode(res.body).cast<int>();
      _newIds = jobject;
    } else {
      throw 'Unable to connect, StatusCode: ${res.statusCode}';
    }
  }

  Future _getTopId() async {
    final articleUrl =
        'https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty';
    final res = await http.get(articleUrl);
    if (res.statusCode == 200) {
      List<int> jobject = jsonDecode(res.body).cast<int>();
      _topIds = jobject;
    } else {
      throw 'Unable to connect, StatusCode: ${res.statusCode}';
    }
  }

  Future<Article> _getArticle(int id) async {
    final articleUrl = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final res = await http.get(articleUrl);
    if (res.statusCode == 200) {
      return parseArticle(res.body);
    } else {
      throw 'Unable to connect, StatusCode: ${res.statusCode}';
    }
  }
}
