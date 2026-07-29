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
