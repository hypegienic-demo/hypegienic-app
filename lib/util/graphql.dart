import 'dart:convert';

dynamic _removeNull(dynamic object) {
  if(object is Map) {
    object.removeWhere((key, value) =>
      value == null
    );
    return object.map((key, value) =>
      MapEntry(key, _removeNull(value))
    );
  } else {
    return object;
  }
}
String encode(dynamic parameter) {
  return json.encode(_removeNull(parameter))
    .replaceAll(RegExp(r'^\{|\}$'), '')
    .replaceAllMapped(RegExp(r'\"([a-zA-Z0-9]+)\"\:'), (m) => '${m[1]}:');
}