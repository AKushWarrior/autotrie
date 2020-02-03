import 'datatree/tree.dart';

class AutoComplete {
  TrieSearchTree _tree;

  AutoComplete() {
    _tree = TrieSearchTree();
  }

  /// Add an entry to the engine.
  ///
  /// The engine will now include `entry' as a search result. If you enter a word
  /// multiple times, it will be prioritized in the search results, since search
  /// results are sorted by number of entries matching that search.
  void enter (String entry) {
    _tree.addWord(entry);
  }

  /// Clear all the entries. The engine is now blank.
  void clearEntries() {
    _tree.root = TrieNode('', false);
  }

  /// Get all the entries in a list. This list is not sorted.
  List<String> get allEntries => _tree.suggestions('');

  /// Suggest entries based on the beginning of the string.
  ///
  /// This method returns a List<String>, which contains the suggestions (entries).
  /// These suggestions are ordered by the number of times the suggestion has been
  /// entered.
  List<String> suggest (String prefix) {
    return _tree.suggestions(prefix);
  }

  /// Returns true if this engine has no entries.
  bool get isEmpty => _tree.root.children.isEmpty;

  /// Returns true if this engine contains `entry`.
  bool contains (String entry) => _tree.search(entry);

  /// Deletes `entry` from the engine if it exists.
  ///
  /// If `entry` is not in the list, it will do nothing.
  void delete (String entry) => _tree.remove(entry);
}
