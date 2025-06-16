// lib/screens/about_screen.dart
import 'package:flutter/material.dart';

// ───── helper model ───────────────────────────────────────────
class Contributor {
  final String name;
  final String note;
  final IconData icon;
  const Contributor(this.name, this.note, {this.icon = Icons.person});
}

// hard-coded data for the list
const contributors = <Contributor>[
  Contributor(
    'Kamil Wysocki',
    'Pytania z oryginalnego teleturnieju „1 z 10”',
  ),
  Contributor(
    'Amelia Barczyk',
    'Nowe pytania, kategorie Harry Potter i Star Wars',
  ),
  Contributor(
    'CharGPT o3',
    'Nowe pytania',
    icon: Icons.smart_toy_outlined,   // 🤖
  ),
];

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O aplikacji / Podziękowania'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Jeden z Dziesięciu\n© 2025 Szymon Marciniak',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Współtwórcy pytań:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
      ListView.separated(
        shrinkWrap: true,                    // tell it to take only the space it needs
        physics: const NeverScrollableScrollPhysics(),  // disable its own scrolling
        padding: const EdgeInsets.all(16),
        itemCount: contributors.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (_, i) {
          final c = contributors[i];
          return ListTile(
            leading: Icon(c.icon, size: 32),
            title: Text(c.name),
            subtitle: Text(c.note),
          );
        },),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Polityka prywatności'),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
        ],
      ),
    );
  }
}
