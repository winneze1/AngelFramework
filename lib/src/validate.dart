import 'package:angel_validate/angel_validate.dart';

var articleValidator = Validator({
  'email': isNonEmptyString,
  'password': isNonEmptyString,
  'title*': isNonEmptyString,
  'slug': isNonEmptyString,
  'publish_date*': (String date) {
    return RegExp(r'^\d{4}\-\d{2}\-\d{2}$').hasMatch(date);
  },
}, customErrorMessages: {
  'email': 'Please enter a email',
  'password': 'Please enter a password',
  'title': 'Please enter a valid title',
  'slug': 'Please enter a valid slug',
  'publish_date': 'Please enter a valid publish date',
});

var searchValidator = Validator({'q*': isNonEmptyString},
    customErrorMessages: {'q': 'Please enter input to search'});
