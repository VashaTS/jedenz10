import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeden_z_dziesieciu/models/player.dart';

void main() {
  test('Player starts with the given lives and zero score', () {
    final player = Player('Anna', const AssetImage('assets/default_icon_new.png'), 3);

    expect(player.name, 'Anna');
    expect(player.lives, 3);
    expect(player.answeredCount, 0);
    expect(player.correctAnswers, 0);
    expect(player.points, 0);
  });
}
