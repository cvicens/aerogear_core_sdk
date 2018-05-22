 class MobileService {
  final String id;
  final String name;
  final String type;
  final String url;
  final Map<String, dynamic> config;

  const MobileService({this.id, this.name, this.type, this.url, this.config});

  String toString() {
    return 'MobileService [id: ' + id + ', name: ' + name + ', type: ' + type + ' url: ' + url + ']';
  }
}