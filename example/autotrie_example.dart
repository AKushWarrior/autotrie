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