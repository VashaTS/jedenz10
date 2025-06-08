import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final List<String> allCategories;
  final Set<String>  initialSelection;
  final Map<String, int> counts;

  const CategoryScreen({
    super.key,
    required this.allCategories,
    required this.initialSelection,
    required this.counts,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Set<String> _current;

  @override
  void initState() {
    super.initState();
    _current = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorie pytań'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () => setState(() => _current = {...widget.allCategories}),
            child: const Text('Zaznacz wszystkie', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: widget.allCategories.map((cat) {
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
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _current),
        icon: const Icon(Icons.check),
        label: const Text('Użyj'),
      ),
    );
  }
}
