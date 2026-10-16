import 'package:flutter/widgets.dart';

/// A single dropdown choice with [key], display [value], and optional [code].
///
/// When the user types a custom value, [code] is usually auto-generated
/// (e.g. `"New Item"` → `"new-item"`).
class SelectOptions {
  /// Unique identifier for this option.
  final String key;

  /// Text shown in the field and menu.
  final String value;

  /// Optional machine-friendly code (slug).
  final String? code;

  /// Optional leading icon shown in the menu row.
  final IconData? icon;

  /// Optional extra payload for the consumer app.
  final Object? data;

  /// Creates a selectable option.
  const SelectOptions({
    required this.key,
    required this.value,
    this.code,
    this.icon,
    this.data,
  });

  /// Returns a copy with selected fields replaced.
  SelectOptions copyWith({
    String? key,
    String? value,
    String? code,
    IconData? icon,
    Object? data,
  }) {
    return SelectOptions(
      key: key ?? this.key,
      value: value ?? this.value,
      code: code ?? this.code,
      icon: icon ?? this.icon,
      data: data ?? this.data,
    );
  }

  /// JSON-friendly map (icon / data are omitted).
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      if (code != null) 'code': code,
    };
  }

  /// Creates an option from a simple map.
  factory SelectOptions.fromMap(Map<String, dynamic> map) {
    return SelectOptions(
      key: map['key']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      code: map['code']?.toString(),
    );
  }

  /// Slug-style code from free text (`"New Item"` → `"new-item"`).
  static String generateCode(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '_');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectOptions &&
        other.key == key &&
        other.value == value &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(key, value, code);

  @override
  String toString() =>
      'SelectOptions(key: $key, value: $value, code: $code)';
}
