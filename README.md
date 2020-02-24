# AutoTrie

A versatile library which solves autocompletion in Dart/Flutter. It is based around
a space-efficient implementation of Trie which uses variable-length lists. With this, serving
auto-suggestions is both fast and no-hassle. Suggestions are also sorted by how often 
they've been entered and subsorted by recency of entry, for search-engine-like results.

Read more about Trie [here][trie].

[trie]: https://medium.com/basecs/trying-to-understand-tries-3ec6bede0014

## Usage

A usage example is provided below. Check the API Reference for detailed docs:

```dart
import 'package:autotrie/autotrie.dart';

void main() {
  var engine = AutoComplete(); //You can also initialize with a starting databank.

  engine.enter('more'); // Enter more thrice.
  engine.enter('more');
  engine.enter('more');

  engine.enter('moody'); // Enter moody twice.
  engine.enter('moody');

  engine.enter('morose'); // Enter scattered words (with mo).
  engine.enter('morty');
  engine.enter('moment');
  engine.enter('momentum');

  engine.enter('sorose'); // Enter scattered words (without mo).
  engine.enter('sorty');

  engine.delete('morose'); // Delete morose.

  // Check if morose is deleted.
  print('Morose deletion check: ${engine.contains('morose')}');

  // Check if engine is empty.
  print('Engine emptiness check: ${engine.isEmpty}');

  // Suggestions starting with 'mo'.
  // They've been sorted by frequency and subsorted by recency.
  print("'mo' suggestions: ${engine.suggest('mo')}");
  // Result: [more, moody, momentum, moment, morty]

  // Get all entries.
  // They've been sorted by frequency and subsorted by recency.
  print('All entries: ${engine.allEntries}');
  // Result: [more, moody, sorty, sorose, momentum, moment, morty]
}

```

## Hive Integration
- [Hive][hive] is a speedy, local, and key-value database for Dart/Flutter. Go check it out if you haven't already!
- Hive integration is now available with autotrie:
    - Uses the AutoCompleteBox class, which extends Hive's Box class.
    - Call `refreshAuto` after making changes to build the autocomplete engine
    - You can then use `searchKeys(String prefix)` and `searchValues(String prefix)` to get auto-suggestions.

[hive]: https://pub.dev/packages/hive

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/AKushWarrior/autotrie/issues

---
###### This library and its contents are subject to the terms of the Mozilla Public License, v. 2.0.
###### © 2020 Aditya Kishore