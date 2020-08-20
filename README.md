# AutoTrie

A versatile library which solves autocompletion in Dart/Flutter. It is based around
a space-efficient implementation of Trie which uses variable-length lists. With this, serving
auto-suggestions is both fast and no-hassle. Suggestions are also sorted by how often 
they've been entered and subsorted by recency of entry, for search-engine-like results.

Read more about Trie [here][trie].

[trie]: https://medium.com/basecs/trying-to-understand-tries-3ec6bede0014

## A Brief Note

It takes time, effort, and mental power to keep this package updated, useful, and
improving. If you used or are using the package, I'd appreciate it if you could spare a few 
dollars to help me continue development.

[![PayPal](https://img.shields.io/static/v1?label=PayPal&message=Donate&color=blue&logo=paypal&style=for-the-badge&labelColor=black)](https://www.paypal.me/kishoredev)

## Usage

A usage example is provided below. Check the API Reference for detailed docs:

```dart
import 'package:autotrie/autotrie.dart';

void main() {
  // You are allowed to initialize with a starting databank by passing a `bank` parameter.
  var engine = AutoComplete(engine: SortEngine.configMulti(Duration(seconds: 1), 15, 0.5, 0.5));

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
  print('Morose deletion check: ${!engine.contains('morose')}');

  // Check if engine is empty.
  print('Engine emptiness check: ${engine.isEmpty}');
 
  // They've been ranked by frequency and recency. Since they're all so similar
  // in recency, frequency takes priority.
  print("'mo' suggestions: ${engine.suggest('mo')}");
  // Result: [more, moody, momentum, moment, morty]

  // Get all entries.
  // They've *not* been sorted.
  // Use `engine.suggest('')` to get all entries sorted` 
  print('All entries: ${engine.allEntries}');
  // Result: [more, moody, sorty, sorose, momentum, moment, morty]
}

```

## Sorting
The AutoComplete constructor takes a SortEngine, which it uses to sort the result of the autocompletion operation.
There are a few different modes it can operate in:

* SortEngine.entriesOnly() -> AutoComplete results are only sorted by number of entries in the engine (High to Low)
* SortEngine.msOnly() -> AutoComplete results are only sorted by how much time has passed since their last entry (Low to High)
* SortEngine.simpleMulti() ->
    - Sorted using two logistic curves, one for ms and one for entries
        * The ms curve is set to use 3 years (a LOT) as the upper end of how far back entries could have been entered
        * The entries curve is set to use 30 entries as the max amount of entries
        * These values are highly arbitrary and not likely to fit your project; this mode is **not** recommended unless
        you are just playing around.
    - Takes two weights (one for recency and one for entries) which can be used to balance how heavily each factor
    should affect the final sorting.
* SortEngine.configMulti() ->
    - Sorted using two logistic curves, one for ms and one for entries
        * The ms curve is balanced using a parameter (a Duration) for the max time since entry in this engine.
        * The entries curve is balanced using a parameter (an int) for the max amount of entries in this engine.
        * If you know approximately how old and how big this AutoComplete engine is, it is **highly** recommended that
        you use this mode.
    - Takes two weights (one for recency and one for entries) which can be used to balance how heavily each factor
    should affect the final sorting.
    
## Basic File Persistence
AutoComplete is natively capable of writing itself to and reading itself from a file. To do this, persist to a file
using the `persist` method (it takes a `File` object):
`await engine.persist(myFile);`

Then you can rebuild using `AutoComplete.fromFile` (it takes a `File` along with the mandatory `SortEngine`):
`var engine = AutoComplete.fromFile(file: myFile, engine: SortEngine.entriesOnly());`

This persistence will preserve all the metadata (last insert, number of entries) in the table as well as the 
core data (the Strings themselves).

## Hive Integration
- [Hive][hive] is a speedy, local, and key-value database for Dart/Flutter. Go check it out if you haven't already!
- Hive integration is now available with autotrie:
    - Our way of integration uses extension methods.
    - Import Hive and AutoTrie, and create a normal Hive box using `Hive.openBox('nameHere')`.
    - You can then call `searchKeys(String prefix)` and `searchValues(String prefix)` on that box to get auto-suggestions.
    - There is no sorting options: only entry-level sorting is available.

[hive]: https://pub.dev/packages/hive

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/AKushWarrior/autotrie/issues

---
###### This library and its contents are subject to the terms of the Mozilla Public License, v. 2.0.
###### © 2020 Aditya Kishore