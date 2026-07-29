import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFields extends StatefulWidget {
  const TextFormFields({
    super.key,
    this.hintText,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.readOnly = false,
    this.textEditingController,
    this.contentPadding = const EdgeInsets.all(16),
    // this.initialValue,
    this.autoFocus = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.label = '',
    this.labelStyle,
    this.fieldStyle,
    this.hintStyle,
    this.errorStyle,
    this.borderColor = Colors.grey,
    this.focusColor = Colors.green,
    this.cursorColor = Colors.green,
    this.focusBorderColor = Colors.green,
    this.focusNode,
    this.textInputType = TextInputType.text,
    this.decoration,
    this.dense = true,
    this.icon,
    this.image,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    this.inputFormatter,
    this.onEditingComplete,
    this.onTap,
    this.obscuringCharacter = '•',
    this.filled = true,
    this.fillColor = Colors.white,
    this.isBorder = true,
    this.isPrefix = false,
    this.prefixText,
    this.suffixText = '',
    this.suffixIconConstraints,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.borderType = InputBorderType.outline,
    this.prefixStyle,
    this.suffixStyle,
    this.errorText,
  });

  final String? hintText;
  final TextAlign textAlign;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? textEditingController;
  final EdgeInsetsGeometry contentPadding;

  // final String? initialValue;
  final bool autoFocus;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? fieldStyle;
  final TextStyle? errorStyle;
  final String? errorText;
  final String suffixText;
  final TextStyle? suffixStyle;
  final FocusNode? focusNode;
  final TextInputType textInputType;
  final bool dense;
  final Widget? icon;
  final Widget? image;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color borderColor;
  final Color focusColor;
  final Color focusBorderColor;
  final Color cursorColor;
  final Function(String s)? onChanged;
  final String? Function(String? s)? validator;
  final Function(String? s)? onSaved;
  final Function(String s)? onFieldSubmitted;
  final Function()? onEditingComplete;
  final Function()? onTap;
  final String obscuringCharacter;
  final List<TextInputFormatter>? inputFormatter;
  final bool filled;
  final Color fillColor;
  final bool isBorder;
  final BoxConstraints? suffixIconConstraints;
  final bool isPrefix;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final BorderRadius borderRadius;
  final InputBorderType? borderType;
  final InputDecoration? decoration;

  @override
  State<StatefulWidget> createState() {
    return _TextFormFieldsState();
  }
}

class _TextFormFieldsState extends State<TextFormFields> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardAppearance: Brightness.light,
      cursorColor: widget.cursorColor,
      textAlign: widget.textAlign,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      controller: widget.textEditingController,
      // initialValue: widget.initialValue,
      maxLines: widget.maxLines,
      minLines: widget.maxLines,
      obscureText: widget.obscureText,
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      keyboardType: widget.textInputType,
      style: widget.fieldStyle ??
          const TextStyle(fontSize: 14, color: Colors.black87),
      decoration:
      widget.decoration ??
          InputDecoration(
            errorText: widget.errorText,
            isDense: widget.dense,
            filled: widget.filled,
            fillColor: widget.fillColor,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                const TextStyle(fontSize: 14, color: Colors.grey),
            errorStyle: widget.errorStyle ??
                const TextStyle(fontSize: 12, color: Colors.red),
            prefixText: (widget.isPrefix) ? widget.prefixText : '',
            prefixStyle: widget.prefixStyle,
            prefixIcon: widget.prefixIcon ?? widget.prefixIcon,
            icon: widget.icon ?? widget.icon,
            contentPadding: widget.contentPadding,
            suffixText: widget.suffixText,
            suffixStyle: widget.suffixStyle,
            suffixIconConstraints: widget.suffixIconConstraints,
            suffixIcon: widget.suffixIcon ?? widget.suffixIcon,
            focusColor: widget.focusColor,
            border: inputBorderStyle(borderType: widget.borderType!),
            errorBorder: inputBorderStyle(borderType: widget.borderType!),
            focusedBorder: inputBorderStyle(borderType: widget.borderType!),
            enabledBorder: inputBorderStyle(borderType: widget.borderType!),
            focusedErrorBorder: inputBorderStyle(
              borderType: widget.borderType!,
            ),
            labelText: widget.label,
            labelStyle: widget.labelStyle ??
                const TextStyle(fontSize: 14, color: Colors.black87),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
      obscuringCharacter: widget.obscuringCharacter,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatter,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
    );
  }

  InputBorder inputBorderStyle({required InputBorderType borderType}) {
    InputBorder inputBorder = InputBorder.none;
    if (borderType == InputBorderType.outline) {
      inputBorder = OutlineInputBorder(
        borderRadius: widget.borderRadius,
        borderSide: BorderSide(
          width: 1.0,
          color: widget.borderColor,
          style: widget.isBorder ? BorderStyle.solid : BorderStyle.none,
        ),
      );
    } else if (borderType == InputBorderType.underline) {
      inputBorder = const UnderlineInputBorder(borderRadius: BorderRadius.zero);
    } else {
      inputBorder = InputBorder.none;
    }
    return inputBorder;
  }
}

enum InputBorderType { outline, underline, none }
