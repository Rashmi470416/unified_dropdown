# unified_dropdown

A Flutter **creatable + searchable** dropdown: pick an existing option, type to filter, or add a new value. New values get an auto-generated code (e.g. `"New Item"` → `"new-item"`).

Works on **Android, iOS, Web, Windows, macOS, and Linux** — pure Flutter, no native plugin code.

## Features

- **Create or select** — type a new value or pick from the list
- **Live search** — filter by value, code, or key as you type
- **Clear button** — reset the field in one tap
- **Validation** — optional required-field support
- **Auto code** — slug generated for custom values

## Installation

```yaml
dependencies:
  unified_dropdown: ^0.1.0
```

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:unified_dropdown/unified_dropdown.dart';

class DropdownDemoPage extends StatefulWidget {
  const DropdownDemoPage({super.key});

  @override
  State<DropdownDemoPage> createState() => _DropdownDemoPageState();
}

class _DropdownDemoPageState extends State<DropdownDemoPage> {
  SelectOptions? _selectedOption;

  final List<SelectOptions> _options = const [
    SelectOptions(key: '1', value: 'Option-1', code: 'op-1'),
    SelectOptions(key: '2', value: 'Option-2', code: 'op-2'),
    SelectOptions(key: '3', value: 'Option-3', code: 'op-3'),
    SelectOptions(key: '4', value: 'Flutter', code: 'flutter'),
    SelectOptions(key: '5', value: 'Dart', code: 'dart'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unified Dropdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UnifiedDropdown(
              isInputField: true,
              items: _options,
              initialValue: _selectedOption,
              fieldHintText: 'Type to search or add…',
              isValidationRequired: true,
              requiredValidationText: 'Please select or enter a value',
              showClearButton: true,
              enableSearch: true,
              onSelected: (option) {
                setState(() => _selectedOption = option);
              },
              onCleared: () {
                setState(() => _selectedOption = null);
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Selected: ${_selectedOption?.value ?? 'None'}'
              '${_selectedOption?.code != null ? ' (${_selectedOption!.code})' : ''}',
            ),
          ],
        ),
      ),
    );
  }
}
```

## Props

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `List<SelectOptions>` | required | Options in the menu |
| `onSelected` | `ValueChanged<SelectOptions>` | required | Called when an option is chosen or created |
| `isInputField` | `bool` | required | `true` = allow typing new values |
| `initialValue` | `SelectOptions?` | `null` | Pre-selected option |
| `isValidationRequired` | `bool` | `false` | Require a non-empty value |
| `requiredValidationText` | `String` | `'Please select a value'` | Validation error text |
| `fieldHintText` | `String?` | `null` | Field hint |
| `enableSearch` | `bool` | `true` | Filter menu by typed text |
| `showClearButton` | `bool` | `true` | Show clear (X) control |
| `onCleared` | `VoidCallback?` | `null` | Fired when cleared |
| `enabled` | `bool` | `true` | Enable / disable the field |
| `accentColor` | `Color` | `Colors.greenAccent` | Dropdown arrow button color |
| `maxMenuHeight` | `double` | `280` | Popup max height |
| `emptyStateText` | `String` | `'No matches found'` | Empty search message |

### `SelectOptions`

| Field | Type | Description |
|-------|------|-------------|
| `key` | `String` | Unique id |
| `value` | `String` | Display text |
| `code` | `String?` | Optional slug / code |

Helpers: `copyWith`, `toMap`, `fromMap`, `SelectOptions.generateCode(String)`.

## Example app

```bash
cd example
flutter run
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
