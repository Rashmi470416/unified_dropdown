

import 'package:flutter/material.dart';
import 'package:unified_dropdown/widget/text_form_fields.dart';

import 'model/select_option.dart';

/// Creatable + selectable dropdown that returns [SelectOptions] (id + value).
class UnifiedDropdown extends StatefulWidget {
  const UnifiedDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    required this.isInputField,
    this.initialValue,
    this.isValidationRequired = false,
    this.requiredValidationText = 'Please select a value',
    this.fieldHintText,
  });

  /// When true, user can type a new value; when false, select from list only.
  final bool isInputField;

  final List<SelectOptions> items;
  final ValueChanged<SelectOptions> onSelected;
  final SelectOptions? initialValue;
  final bool isValidationRequired;
  final String requiredValidationText;
  final String? fieldHintText;

  @override
  State<UnifiedDropdown> createState() => _UnifiedDropdownState();
}

class _UnifiedDropdownState extends State<UnifiedDropdown> {
  SelectOptions? _selected;
  final _formFieldKey = GlobalKey<FormFieldState<SelectOptions>>();
  final TextEditingController _fieldController = TextEditingController();
  final GlobalKey _fieldKey = GlobalKey();
  static String generateCode(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '_');
  }
  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    _syncFieldText();
  }

  @override
  void didUpdateWidget(UnifiedDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue;
    final prev = oldWidget.initialValue;
    if (prev?.key != next?.key || prev?.value != next?.value) {
      setState(() => _selected = next);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncFieldText();
        _formFieldKey.currentState?.didChange(_selected);
      });
    }
  }

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  void _syncFieldText() {
    _fieldController.text =
    _isPlaceholder(_selected) ? '' : (_selected?.value ?? '');
  }

  bool _isPlaceholder(SelectOptions? option) {
    if (option == null) return true;
    return option.key == '0';
  }

  SelectOptions? _findExistingByValue(String value) {
    if (value.isEmpty) return null;
    return widget.items.cast<SelectOptions?>().firstWhere(
          (item) => item?.value.toLowerCase() == value.toLowerCase(),
      orElse: () => null,
    );
  }

  Future<void> _showMenu(FormFieldState<SelectOptions> field) async {
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final size = box.size;
    final menuWidth = _menuWidth(size.width);

    final selected = await showMenu<SelectOptions>(
      context: context,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        overlayBox.size.width - (offset.dx + menuWidth),
        overlayBox.size.height - (offset.dy + size.height + 4),
      ),
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: 280,
      ),
      items: _menuItems(),
    );

    if (selected == null) return;
    _applySelection(field, selected);
  }

  double _menuWidth(double fieldWidth) {
    const textStyle = TextStyle(fontSize: 14, color: Colors.black);
    var maxTextWidth = 0.0;
    for (final item in widget.items) {
      final painter = TextPainter(
        text: TextSpan(text: item.value, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width > maxTextWidth) maxTextWidth = painter.width;
    }
    final contentWidth = maxTextWidth + 40;
    return contentWidth > fieldWidth ? contentWidth : fieldWidth;
  }

  List<PopupMenuEntry<SelectOptions>> _menuItems() {
    final items = widget.items
        .map(
          (option) => PopupMenuItem<SelectOptions>(
        value: option,
        child: Text(
          option.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    )
        .toList();

    final typedValue = _fieldController.text.trim();
    final existing = _findExistingByValue(typedValue);
    if (widget.isInputField && typedValue.isNotEmpty && existing == null) {
      items.insert(
        0,
        PopupMenuItem<SelectOptions>(
          value: SelectOptions(
            key: '',
            value: typedValue,
            code:generateCode(typedValue),
          ),
          child: Text(
            'Add "$typedValue"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
          ),
        ),
      );
    }

    return items;
  }

  void _applySelection(
      FormFieldState<SelectOptions> field,
      SelectOptions selected,
      ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selected = selected.key == '0' ? null : selected;
        _syncFieldText();
      });
      field.didChange(_selected);
      widget.onSelected(selected);
    });
  }

  void _submitField(FormFieldState<SelectOptions> field) {
    final typedValue = _fieldController.text.trim();
    if (typedValue.isEmpty) {
      if (!widget.isInputField) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _selected = null);
          field.didChange(null);
        });
      }
      return;
    }

    final existing = _findExistingByValue(typedValue);
    if (existing != null) {
      _applySelection(field, existing);
      return;
    }
    if (!widget.isInputField) return;

    _applySelection(
      field,
      SelectOptions(
        key: '',
        value: typedValue,
        code:generateCode(typedValue),
      ),
    );
  }

  void _syncTypedInput(String rawValue) {
    if (!widget.isInputField) return;

    final typedValue = rawValue.trim();
    if (typedValue.isEmpty) return;

    final existing = _findExistingByValue(typedValue);
    final next = existing ??
        SelectOptions(
          key: '',
          value: typedValue,
          code: generateCode(typedValue),
        );

    if (_selected?.key == next.key && _selected?.value == next.value) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selected = next);
      widget.onSelected(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField<SelectOptions>(
      key: _formFieldKey,
      initialValue: _selected,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) {
        if (widget.isValidationRequired && (value == null || value.key == '0')) {
          if (widget.isInputField && _fieldController.text.trim().isNotEmpty) {
            return null;
          }
          return widget.requiredValidationText;
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormFields(
              key: _fieldKey,
              textEditingController: _fieldController,
              readOnly: !widget.isInputField,
              hintText: widget.fieldHintText ??
                  (widget.isInputField ? 'Enter ...' : 'Select ...'),
              borderRadius: BorderRadius.circular(10),
              textInputType: TextInputType.text,
              borderColor: field.hasError
                  ? Colors.red
                  : Colors.grey.shade300,
              onTap: widget.isInputField ? null : () => _showMenu(field),
              onChanged: (_) => _syncTypedInput(_fieldController.text),
              onFieldSubmitted: (_) => _submitField(field),
              suffixIcon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 30),
                  color: Colors.white,
                  onPressed: () => _showMenu(field),
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}
