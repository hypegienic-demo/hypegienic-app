class ApplicationInterfaceError implements Exception {
  final String message;
  ApplicationInterfaceError(this.message) : super();

  @override
  String toString() {
    return 'ApplicationInterfaceError: ' + message;
  }
}

class File {
  String id;
  String type;
  String url;

  File(dynamic file) :
    this.id = file['id'],
    this.type = file['type'],
    this.url = file['url'];
}