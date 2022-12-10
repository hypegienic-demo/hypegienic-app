import 'package:intl/intl.dart';

import './string.dart';

String formatDate(DateTime date, {String? format}) {
  final DateFormat formatter = DateFormat(format ?? 'MMM d, yyyy');
  return formatter.format(date);
}

String displayTimePassed(DateTime date) {
  final diff = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
  if(diff < 59.5 * 60 * 1000) {
    return '${pluralize((diff / (60 * 1000)).round(), 'minute')} ago';
  } else if(diff < 23.5 * 60 * 60 * 1000) {
    return '${pluralize((diff / (60 * 60 * 1000)).round(), 'hour')} ago';
  } else if(diff < 6.5 * 24 * 60 * 60 * 1000) {
    return '${pluralize((diff / (24 * 60 * 60 * 1000)).round(), 'day')} ago';
  } else if(diff < 3.5 * 7 * 24 * 60 * 60 * 1000) {
    return '${pluralize(
      (diff / (7 * 24 * 60 * 60 * 1000)).round(),
      'week'
    )} ago';
  } else {
    return formatDate(date);
  }
}