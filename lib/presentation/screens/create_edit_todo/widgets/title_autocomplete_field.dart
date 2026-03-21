import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;

class TitleAutocompleteField extends ConsumerStatefulWidget {
  const TitleAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  ConsumerState<TitleAutocompleteField> createState() =>
      _TitleAutocompleteFieldState();
}

class _TitleAutocompleteFieldState
    extends ConsumerState<TitleAutocompleteField> {
  Timer? _debounce;
  List<String> _suggestions = [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: kAutocompleteDebounceMills),
      () {
        if (value.trim().isNotEmpty) {
          ref.read(autocompleteProvider(value.trim()).future).then((results) {
            if (mounted) {
              setState(() => _suggestions = results);
            }
          });
        } else {
          setState(() => _suggestions = []);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDir =
        unicode_utils.detectTextDirection(widget.controller.text);
    final flutterDir = textDir == unicode_utils.TextDirection.rtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }
        return _suggestions;
      },
      onSelected: (selection) {
        widget.controller.text = selection;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: selection.length),
        );
        widget.onChanged?.call(selection);
      },
      fieldViewBuilder: (context, textController, fieldFocusNode, onFieldSubmitted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.controller.text.isNotEmpty &&
              textController.text != widget.controller.text) {
            textController.text = widget.controller.text;
          }
        });
        return TextFormField(
          controller: textController,
          focusNode: fieldFocusNode,
          enabled: widget.enabled,
          textDirection: flutterDir,
          decoration: const InputDecoration(
            labelText: AppStrings.titleHint,
            prefixIcon: Icon(Icons.title),
          ),
          validator: widget.validator,
          onChanged: (value) {
            widget.controller.text = value;
            _onChanged(value);
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}
