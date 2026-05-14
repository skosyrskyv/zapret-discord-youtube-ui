import 'dart:convert';

class ScriptModel {
  ScriptModel({required this.name});

  final String name;

  String get nameWithoutExtension => name.split('.').first;

  static ScriptModel fromJson(String json) {
    try {
      final Map<String, dynamic> map = jsonDecode(json);
      return fromMap(map);
    } catch (_) {
      rethrow;
    }
  }

  static ScriptModel fromMap(Map<String, dynamic> map) {
    return ScriptModel(name: map['name']);
  }

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return other is ScriptModel && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
