# unified_dropdown

A Flutter dropdown that supports **selecting an existing option** or **typing a new value**. When the user adds a custom value, a code is generated automatically (e.g. `"New Item"` → `"new-item"`).

Each choice is a `SelectOptions` object with `key`, `value`, and optional `code`.

## Features

- Select from a list of options
- Optional free-text input (`isInputField: true`) to add new values
- Optional validation for required fields
- Returns `SelectOptions` via `onSelected`

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  unified_dropdown: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:unified_dropdown/model/select_option.dart';
import 'package:unified_dropdown/unified_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DropdownDemoPage(),
    );
  }
}

class DropdownDemoPage extends StatefulWidget {
  const DropdownDemoPage({super.key});

  @override
  State<DropdownDemoPage> createState() => _DropdownDemoPageState();
}

class _DropdownDemoPageState extends State<DropdownDemoPage> {
  SelectOptions? _selectedOption;

  final List<SelectOptions> _options = [
    SelectOptions(key: '1', value: 'Option-1', code: 'op-1'),
    SelectOptions(key: '2', value: 'Option-2', code: 'op-2'),
    SelectOptions(key: '3', value: 'Option-3', code: 'op-3'),
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
              fieldHintText: 'Enter hint text',
              isValidationRequired: true,
              requiredValidationText: 'Name required',
              onSelected: (option) {
                setState(() => _selectedOption = option);
              },
            ),
            const SizedBox(height: 12),
            Text('Selected: ${_selectedOption?.value ?? 'None'}'),
          ],
        ),
      ),
    );
  }
}
```

### Props

| Parameter | Type | Description |
|-----------|------|-------------|
| `items` | `List<SelectOptions>` | Options shown in the menu |
| `onSelected` | `ValueChanged<SelectOptions>` | Called when an option is chosen or created |
| `isInputField` | `bool` | `true` = allow typing new values; `false` = select only |
| `initialValue` | `SelectOptions?` | Pre-selected option |
| `isValidationRequired` | `bool` | Show an error when empty (default: `false`) |
| `requiredValidationText` | `String` | Error message when validation fails |
| `fieldHintText` | `String?` | Hint text for the field |

## Example app

See the full demo under [`example/`](example/).

## License

BSD 3-Clause. See [LICENSE](LICENSE).
