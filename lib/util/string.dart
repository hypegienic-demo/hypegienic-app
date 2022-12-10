String pluralize(int amount, String verb) {
  return '$amount ${
    amount <= 1
      ? verb
      : verb.endsWith('y') &&
        !['a', 'e', 'i', 'o', 'u']
          .any((letter) => verb.endsWith('${letter}y'))
      ? verb.replaceAll(RegExp(r'y$'), 'ies')
      : verb + 's'
  }';
}