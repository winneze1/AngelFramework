import 'package:angel_framework/angel_framework.dart';
import 'package:angel_validate/angel_validate.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'model/article.dart';
import 'dart:io';
import './validate.dart';
import './paginator.dart';

AngelConfigurer configServer() => (Angel app) {
      app.get('/', (req, res) async {
        var articleService = app.findService('articles');
        var collection = req.container.findByName('datastore');
        var count = await collection.count();
        final page = req.queryParameters['page'];
        final pageSkip = page is String ? int.tryParse(page) : 1;
        final itemsPerPage = 5;
        final totalPageIndex = (count / itemsPerPage).ceil(); //101/10 = 11

        if (pageSkip == null) await res.redirect('/');
        var articleList = await articleService.index({
          'query': where
              .sortBy('publish_date', descending: true)
              .skip((pageSkip - 1) * itemsPerPage //2 - 1 = 1 * 3
                  )
              .limit(itemsPerPage),
        });

        var articles = articleList.map((article) {
          return ArticleSerializer.fromMap(article);
        }).toList();
        await res.render('articles', {
          'articles': articles,
          'title': 'home',
          'paginator': Paginatior(
              currentPage: pageSkip,
              previousPage: pageSkip == 1 ? 1 : pageSkip - 1,
              nextPage: pageSkip + 1,
              itemsPerPage: itemsPerPage,
              startIndex: 1,
              endIndex: totalPageIndex)
        });
      });

      app.get('/search', (req, res) async {
        var query = req.queryParameters['q'];
        var articleService = app.findService('articles');

        var validationResult = searchValidator.check(req.queryParameters);
        var templateData = {};

        if (validationResult.errors.isNotEmpty) {
          templateData
              .addAll({'errors': validationResult.errors, 'articles': []});
        } else {
          var filterArticleList = await articleService.index({
            //exist will be > -1
            'query': where.jsQuery('this.title.indexOf("$query") > -1')
          });

          var filterArticles = filterArticleList.map((article) {
            return ArticleSerializer.fromMap(article);
          }).toList();

          templateData['articles'] = filterArticles;
        }

        await res.render('search', {'query': query, ...templateData});
      });

      app.get(
          '/new', (req, res) => res.render('article_form', {'title': 'new'}));

      app.post('/new', (req, res) async {
        await req.parseBody();
        // print(req.bodyAsMap);

        var validationResult = articleValidator.check(req.bodyAsMap);
        var templateData = <String, dynamic>{};

        if (validationResult.errors.isNotEmpty) {
          templateData['errors'] = validationResult.errors;
          var title = req.bodyAsMap['title'];
          var slug = req.bodyAsMap['slug'];
          var publishDate = req.bodyAsMap['publish_date'];
          var content = req.bodyAsMap['content'];

          templateData['article'] = Article(
              title: title.isNotEmpty ? title : null,
              slug: slug.isNotEmpty ? slug : null,
              publishDate:
                  publishDate.isNotEmpty ? DateTime.parse(publishDate) : null,
              content: content.isNotEmpty ? content : null);

          res.statusCode = HttpStatus.badRequest;
        } else {
          var articleService = app.findService('articles');
          var article = ArticleSerializer.fromMap(req.bodyAsMap);

          article.createdAt = DateTime.now();
          article.updatedAt = DateTime.now();

          var createArticle = await articleService.create(article.toJson());

          templateData.addAll({
            'created': true,
            'article': ArticleSerializer.fromMap(createArticle)
          });
        }

        await res.render('article_form', templateData);
      });

      app.get('/posts/:slug', (req, res) async {
        var articleService = app.findService('articles');
        var articleMap = await articleService
            .findOne({'query': where.eq('slug', req.params['slug'])});
        var article = ArticleSerializer.fromMap(articleMap);
        await res.render('article', {'article': article});
      });

      app.get('/posts/:slug/edit', (req, res) async {
        var articleService = app.findService('articles');
        var articleMap = await articleService
            .findOne({'query': where.eq('slug', req.params['slug'])});
        var article = ArticleSerializer.fromMap(articleMap);

        await res.render('article_form', {
          'editing': true,
          'article': article,
        });
      });

      app.post('/posts/:slug/edit', (req, res) async {
        await req.parseBody();
        var articleService = app.findService('articles');
        var methodOverride = req.bodyAsMap['_method'];

        if (methodOverride is String && methodOverride == 'delete') {
          await articleService.remove(req.bodyAsMap['id']);
          await res.redirect('/');
          return;
        }

        var validationResult = articleValidator.check(req.bodyAsMap);
        var templateData = <String, dynamic>{};

        if (validationResult.errors.isNotEmpty) {
          templateData['errors'] = validationResult.errors;

          var id = req.bodyAsMap['id'];
          var title = req.bodyAsMap['title'];
          var slug = req.bodyAsMap['slug'];
          var publishDate = req.bodyAsMap['publish_date'];
          var content = req.bodyAsMap['content'];

          templateData['article'] = Article(
              id: id,
              title: title.isNotEmpty ? title : null,
              slug: slug.isNotEmpty ? slug : null,
              publishDate:
                  publishDate.isNotEmpty ? DateTime.parse(publishDate) : null,
              content: content.isNotEmpty ? content : null);

          res.statusCode = HttpStatus.badRequest;
        } else {
          var article = ArticleSerializer.fromMap(req.bodyAsMap);

          article.updatedAt = DateTime.now();

          var updateArticle =
              await articleService.update(article.id, article.toJson());

          templateData.addAll({
            'edited': true,
            'article': ArticleSerializer.fromMap(updateArticle)
          });
        }

        await res.render('article_form', templateData);
      });

      app.post('/login', (req, res) async {
        await req.parseBody();
        var articleService = app.findService('articles');
        var email = req.bodyAsMap['email'];
        var password = req.bodyAsMap['password'];
        var code = HttpStatus.ok;

        var query = {};
        query.addAll({'email': email, 'password': password});

        try {
          var findUser = await articleService.findOne({'query': query});
          print(findUser);

          if (findUser == null) {
            throw ArgumentError('Incorrect email or password');
          }

          if (findUser != null) {
            var resBody = {
              'email': email,
              'password': password,
              'status_code': code
            };
            await res.json(resBody);
            print('success');
          } else {
            throw ArgumentError('Incorrect email or password');
          }
        } catch (e) {
          res.statusCode = HttpStatus.unauthorized;
          res.json(AngelHttpException.notFound(message: 'User not found'));
          print("fail");
        }
      });

      app.fallback((req, res) => throw AngelHttpException.notFound(
          message: "That route doesn't exist"));
    };
