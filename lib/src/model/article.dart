import 'package:angel_serialize/angel_serialize.dart';
part 'article.g.dart';

DateTime _dateFromString(s) => s is String ? DateTime.parse(s) : null;
String _dateToString(DateTime d) => d == null ? null : d.toString();

@serializable
class _Article extends Model {
  String title;
  String slug;
  String content;

  @SerializableField(
      serializer: #_dateToString,
      deserializer: #_dateFromString,
      serializesTo: String)
  DateTime publishDate;

  static final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  String get fullDate =>
      '${publishDate.day} ${months[publishDate.month - 1]} ${publishDate.year}';
}
