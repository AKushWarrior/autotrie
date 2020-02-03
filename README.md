# AutoTrie

A versatile library which solves autocompletion in Dart/Flutter. It is based around
a space-efficient implementation of Trie which uses variable-length lists. With this, serving
auto-suggestions is both fast and no-hassle. Suggestions are also sorted by how often 
they've been entered, for search-engine-like results.

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

  engine.enter('sorose'); // Enter scattered words (without mo).
  engine.enter('sorty');

  engine.delete('morose'); // Delete morose.

  print(engine.contains('morose')); // Check if morose is deleted.

  print(engine.isEmpty); // Check if engine is empty.

  print(engine.suggest('mo')); // Suggestions starting with 'mo', sorted by frequency.
  // Result: [more, moody, morty]

  print(engine.allEntries); // Get all entries, sorted by frequency.
  // Result: [more, moody, morty, sorose, sorty]
}

// Check the API Reference for the latest information and adv. 
// methods from this class.
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/AKushWarrior/autotrie/issues

---
###### This library and its contents are subject to the terms of the Mozilla Public License, v. 2.0.
###### © 2020 Aditya Kishore