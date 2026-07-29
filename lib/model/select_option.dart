// Model class to hold menu option data (language and theme)
class SelectOptions {
  final String key;
  final String value;
  final String? code;

  SelectOptions({required this.key, required this.value, this.code});

  @override
  String toString() {
    return 'Manu: {Key: $key, Name: $value, Code: $code}';
  }
}
