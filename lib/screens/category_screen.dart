import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/models/caregory_result.dart';

class CategoryScreen extends StatefulWidget {
  final List<String> allCategories;
  final Set<String>  initialSelection;
  final Map<String, int> counts;
  final bool includeAI;

  const CategoryScreen({
    super.key,
    required this.allCategories,
    required this.initialSelection,
    required this.counts,
    required this.includeAI,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Set<String> _current;
  late bool _includeAI;

  @override
  void initState() {
    super.initState();
    _current = {...widget.initialSelection};
    _includeAI = widget.includeAI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorie pytań'),
        backgroundColor: Colors.blue,
        actions: [
      PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (val) => setState(() {
        switch (val) {
          case 'all':   // Zaznacz wszystko
            _current = {...widget.allCategories};
            break;
          case 'none':  // Odznacz wszystko
            _current.clear();
            break;
          case 'invert': // Odwróć
            final allSet = widget.allCategories.toSet();
            _current = allSet.difference(_current).toSet();
        }
      }),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Text('Zaznacz wszystko'),
        ),
        const PopupMenuItem(
          value: 'none',
          child: Text('Odznacz wszystko'),
        ),
        const PopupMenuItem(
          value: 'invert',
          child: Text('Odwróć zaznaczenie'),
        ),
      ],
    ),
    ],
          ),

      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Pytania generowane przez 🤖'),
            value: _includeAI,
            onChanged: (v) => setState(() => _includeAI = v),
          ),
          const Divider(),
          ...widget.allCategories.map((cat) {
          final checked = _current.contains(cat);
          return CheckboxListTile(
            title: Row(
              children: [
                Expanded(child: Text(cat)),
                Text('(${widget.counts[cat] ?? 0})',
                    style: const TextStyle(color: Colors.grey)),
              ]
            ),
            value: checked,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _current.add(cat);
                } else {
                  _current.remove(cat);
                }
              });
            },
          );
        }).toList(),]
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 32),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pop(context,CategoryResult(_current,_includeAI)),
          icon: const Icon(Icons.check),
          label: const Text('Użyj'),
        ),
      )
    );
  }
}
