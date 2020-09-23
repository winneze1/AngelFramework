import 'package:angel_framework/angel_framework.dart';

import 'model/article.dart';

AngelConfigurer configServer() => (Angel app) {
      app.get('/', (req, res) async {
        var articleService = app.findService('articles');
        var articleList = await articleService.index();
        var articles = articleList.map((article) {
          return ArticleSerializer.fromMap(article);
        }).toList();
        await res.render('articles', {'articles': articles});
      });

      app.get('/new', (req, res) => res.render('article_form'));

      app.post('/new', (req, res) async {
        await req.parseBody();
        // print(req.bodyAsMap);
        var articleService = app.findService('articles');
        var article = ArticleSerializer.fromMap(req.bodyAsMap);

        article.createdAt = DateTime.now();
        article.updatedAt = DateTime.now();

        var createArticle = await articleService.create(article.toJson());

        await res.render('article_form', {
          'created': true,
          'article': ArticleSerializer.fromMap(createArticle)
        });
      });
    };
