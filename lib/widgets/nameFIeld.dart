import 'package:flutter/material.dart';

class NameField extends StatefulWidget {
  final String initial;
  final String label;
  final ValueChanged<String> onChanged;
  const NameField({
    super.key,
    required this.initial,
    required this.label,
    required this.onChanged,
  });

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial)
      ..addListener(() => widget.onChanged(_c.text));
  }

  @override
  void didUpdateWidget(covariant NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial && _c.text != widget.initial) {
      _c.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empty = _c.text.trim().isEmpty;
    return TextField(
      controller: _c,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: empty ? 'Imię wymagane' : null,
      ),
    );
  }
}
