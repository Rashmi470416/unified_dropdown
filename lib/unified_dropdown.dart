import 'package:flutter/material.dart';
import 'package:unified_dropdown/widget/text_form_fields.dart';

import 'model/select_option.dart';

export 'model/select_option.dart';

/// Creatable + selectable dropdown that returns [SelectOptions].
///
/// Supports select-only mode, free-text create mode, live search filtering,
/// clear button, custom item builders, and form validation — with the same
/// default look as before.
class UnifiedDropdown extends StatefulWidget {
  /// Creates a unified select / create dropdown.
  const UnifiedDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    required this.isInputField,
    this.initialValue,
    this.isValidationRequired = false,
    this.requiredValidationText = 'Please select a value',
    this.fieldHintText,
    this.enableSearch = true,
    this.showClearButton = true,
    this.enabled = true,
    this.accentColor = Colors.greenAccent,
    this.maxMenuHeight = 280,
    this.emptyStateText = 'No matches found',
    this.addLabelBuilder,
    this.itemBuilder,
    this.onCleared,
    this.menuBorderRadius = 12,
    this.fieldBorderRadius = 10,
  });

  /// When true, user can type a new value; when false, select from list only.
  final bool isInputField;

  /// Options shown in the menu.
  final List<SelectOptions> items;

  /// Called when an option is chosen or created.
  final ValueChanged<SelectOptions> onSelected;

  /// Pre-selected option.
  final SelectOptions? initialValue;

  /// Show an error when empty.
  final bool isValidationRequired;

  /// Error message when validation fails.
  final String requiredValidationText;

  /// Hint text for the field.
  final String? fieldHintText;

  /// When true, menu items are filtered by the current field text.
  final bool enableSearch;

  /// Shows a clear (X) control when a value is selected.
  final bool showClearButton;

  /// Disables interaction when false.
  final bool enabled;

  /// Accent color for the dropdown arrow button (default unchanged).
  final Color accentColor;

  /// Maximum height of the popup menu.
  final double maxMenuHeight;

  /// Shown when search yields no results.
  final String emptyStateText;

  /// Custom label for the "Add …" row. Defaults to `Add "value"`.
  final String Function(String typedValue)? addLabelBuilder;

  /// Optional custom builder for each menu row.
  final Widget Function(BuildContext context, SelectOptions option)? itemBuilder;

  /// Called when the user clears the selection.
  final VoidCallback? onCleared;

  /// Corner radius of the popup menu.
  final double menuBorderRadius;

  /// Corner radius of the text field.
  final double fieldBorderRadius;

  @override
  State<UnifiedDropdown> createState() => _UnifiedDropdownState();
}

class _UnifiedDropdownState extends State<UnifiedDropdown> {
  SelectOptions? _selected;
  final _formFieldKey = GlobalKey<FormFieldState<SelectOptions>>();
  final TextEditingController _fieldController = TextEditingController();
  final GlobalKey _fieldKey = GlobalKey();

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

  bool get _hasClearableValue {
    if (!widget.showClearButton || !widget.enabled) return false;
    if (_isPlaceholder(_selected)) return false;
    return _fieldController.text.trim().isNotEmpty;
  }

  SelectOptions? _findExistingByValue(String value) {
    if (value.isEmpty) return null;
    for (final item in widget.items) {
      if (item.value.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }

  List<SelectOptions> _filteredItems() {
    if (!widget.enableSearch) return widget.items;
    final query = _fieldController.text.trim().toLowerCase();
    if (query.isEmpty || _selected?.value.toLowerCase() == query) {
      return widget.items;
    }
    return widget.items.where((item) {
      final value = item.value.toLowerCase();
      final code = item.code?.toLowerCase() ?? '';
      final key = item.key.toLowerCase();
      return value.contains(query) ||
          code.contains(query) ||
          key.contains(query);
    }).toList();
  }

  Future<void> _showMenu(FormFieldState<SelectOptions> field) async {
    if (!widget.enabled) return;

    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final size = box.size;
    final filtered = _filteredItems();
    final menuWidth = _menuWidth(size.width, filtered);

    final selected = await showMenu<SelectOptions>(
      context: context,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.menuBorderRadius),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        overlayBox.size.width - (offset.dx + menuWidth),
        overlayBox.size.height - (offset.dy + size.height + 4),
      ),
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: widget.maxMenuHeight,
      ),
      items: _menuItems(filtered),
    );

    if (selected == null) return;
    if (selected.key == '__empty__') return;
    _applySelection(field, selected);
  }

  double _menuWidth(double fieldWidth, List<SelectOptions> items) {
    const textStyle = TextStyle(fontSize: 14, color: Colors.black);
    var maxTextWidth = 0.0;
    final labels = <String>[
      ...items.map((e) => e.value),
      if (widget.isInputField) ...[
        widget.addLabelBuilder?.call(_fieldController.text.trim()) ??
            'Add "${_fieldController.text.trim()}"',
      ],
      widget.emptyStateText,
    ];
    for (final label in labels) {
      if (label.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width > maxTextWidth) maxTextWidth = painter.width;
    }
    final contentWidth = maxTextWidth + 56;
    return contentWidth > fieldWidth ? contentWidth : fieldWidth;
  }

  List<PopupMenuEntry<SelectOptions>> _menuItems(List<SelectOptions> filtered) {
    final items = <PopupMenuEntry<SelectOptions>>[];
    final typedValue = _fieldController.text.trim();
    final existing = _findExistingByValue(typedValue);

    if (widget.isInputField && typedValue.isNotEmpty && existing == null) {
      final addLabel =
          widget.addLabelBuilder?.call(typedValue) ?? 'Add "$typedValue"';
      items.add(
        PopupMenuItem<SelectOptions>(
          value: SelectOptions(
            key: '',
            value: typedValue,
            code: SelectOptions.generateCode(typedValue),
          ),
          child: Text(
            addLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      items.add(
        PopupMenuItem<SelectOptions>(
          enabled: false,
          value: const SelectOptions(key: '__empty__', value: ''),
          child: Text(
            widget.emptyStateText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      );
      return items;
    }

    for (final option in filtered) {
      items.add(
        PopupMenuItem<SelectOptions>(
          value: option,
          child: widget.itemBuilder?.call(context, option) ??
              _DefaultMenuItem(
                option: option,
                isSelected: _selected?.key == option.key &&
                    _selected?.value == option.value,
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

  void _clear(FormFieldState<SelectOptions> field) {
    if (!widget.enabled) return;
    setState(() {
      _selected = null;
      _fieldController.clear();
    });
    field.didChange(null);
    widget.onCleared?.call();
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
        code: SelectOptions.generateCode(typedValue),
      ),
    );
  }

  void _syncTypedInput(String rawValue) {
    if (!widget.isInputField) return;

    final typedValue = rawValue.trim();
    if (typedValue.isEmpty) {
      if (_selected != null) {
        setState(() => _selected = null);
      }
      return;
    }

    final existing = _findExistingByValue(typedValue);
    final next = existing ??
        SelectOptions(
          key: '',
          value: typedValue,
          code: SelectOptions.generateCode(typedValue),
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
        if (widget.isValidationRequired &&
            (value == null || value.key == '0')) {
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
              enabled: widget.enabled,
              readOnly: !widget.isInputField,
              hintText: widget.fieldHintText ??
                  (widget.isInputField ? 'Enter ...' : 'Select ...'),
              borderRadius: BorderRadius.circular(widget.fieldBorderRadius),
              textInputType: TextInputType.text,
              borderColor:
                  field.hasError ? Colors.red : Colors.grey.shade300,
              onTap: (!widget.isInputField && widget.enabled)
                  ? () => _showMenu(field)
                  : null,
              onChanged: (_) {
                setState(() {});
                _syncTypedInput(_fieldController.text);
              },
              onFieldSubmitted: (_) => _submitField(field),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hasClearableValue)
                    IconButton(
                      tooltip: 'Clear',
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => _clear(field),
                    ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? widget.accentColor
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(widget.fieldBorderRadius - 2),
                        bottomRight:
                            Radius.circular(widget.fieldBorderRadius - 2),
                      ),
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Open options',
                      icon: const Icon(Icons.arrow_drop_down, size: 30),
                      color: Colors.white,
                      onPressed:
                          widget.enabled ? () => _showMenu(field) : null,
                    ),
                  ),
                ],
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

class _DefaultMenuItem extends StatelessWidget {
  const _DefaultMenuItem({
    required this.option,
    required this.isSelected,
  });

  final SelectOptions option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (option.icon != null) ...[
          Icon(option.icon, size: 18, color: Colors.black87),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            option.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (isSelected)
          const Icon(Icons.check, size: 16, color: Colors.green),
      ],
    );
  }
}
