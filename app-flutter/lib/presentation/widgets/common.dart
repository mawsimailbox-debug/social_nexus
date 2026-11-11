import 'package:flutter/material.dart';

import '../theme.dart';

class Photo extends StatelessWidget {
  const Photo({
    super.key,
    this.height,
    this.width,
    this.alignment = const Alignment(0, -.56),
    this.radius = 0,
    this.backgroundScale,
  });
  final double? height, width;
  final Alignment alignment;
  final double radius;
  final double? backgroundScale;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: backgroundScale == null
        ? Image.asset(
            Tokens.photo,
            height: height,
            width: width,
            fit: BoxFit.cover,
            alignment: alignment,
          )
        : LayoutBuilder(
            builder: (context, box) => CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: null,
              child: OverflowBox(
                alignment: alignment,
                minWidth: box.maxWidth * backgroundScale!,
                maxWidth: box.maxWidth * backgroundScale!,
                minHeight: 0,
                maxHeight: double.infinity,
                child: Image.asset(
                  Tokens.photo,
                  width: box.maxWidth * backgroundScale!,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Tokens.muted,
      ),
    ),
  );
}

class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.items,
    required this.value,
    required this.onSelect,
  });
  final List<String> items;
  final String value;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                selected: item.toLowerCase() == value.toLowerCase(),
                onSelected: (_) => onSelect(item.toLowerCase()),
                selectedColor: Tokens.tan,
                showCheckmark: false,
              ),
            ),
          )
          .toList(),
    ),
  );
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.label});
  final IconData icon;
  final String? label;
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(label == null ? 13 : 23),
      gradient: const LinearGradient(
        colors: [Color(0xFF3B444A), Color(0xFF262D31)],
      ),
    ),
    alignment: Alignment.center,
    child: label == null
        ? Icon(icon, color: Tokens.tan, size: 21)
        : Text(label!, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

class NativeInput extends StatelessWidget {
  const NativeInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.maxLength,
    this.lines = 1,
    this.type,
    this.onSubmitted,
    this.inputKey,
  });
  final String value, hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final int? maxLength;
  final int lines;
  final TextInputType? type;
  final Key? inputKey;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: inputKey ?? ValueKey('$hint-${value.isEmpty}'),
    initialValue: value,
    onChanged: onChanged,
    maxLength: maxLength,
    maxLines: lines,
    keyboardType: type,
    onFieldSubmitted: (_) => onSubmitted?.call(),
    decoration: InputDecoration(hintText: hint),
  );
}
