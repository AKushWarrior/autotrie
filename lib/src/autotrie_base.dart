import 'dart:typed_data';

import 'datatree/tree.dart';
import 'package:hive/hive.dart';

/// Engine for auto-completion of Strings.
///
/// Add entries to build up the suggestion bank. Then, you can use the suggest
/// method to get the auto-completions for the beginning of a String.
class AutoComplete {
  TrieSearchTree _tree;
  bool _hasChanged;

  /// Constructs an instance of `AutoComplete`.
  ///
  /// If you pass a [bank] parameter, the engine will have all the Strings in
  /// bank as search results.
  ///
  /// If you enter a word multiple times, it will be prioritized in the search
  /// results, since search results are sorted by number of times entered.
  ///
  /// If multiple words have the same number of entries, they are sorted by recency,
  /// with the most recently entered word being on top.
  AutoComplete({List<String> bank}) {
    _tree = TrieSearchTree();
    _hasChanged = false;
    bank ??= <String>[];
    for (var x in bank) {
      enter(x);
      _hasChanged = true;
    }
  }

  /// Add an entry to the engine.
  ///
  /// The engine will now include `entry' as a search result. If you enter a word
  /// multiple times, it will be prioritized in the search results, since search
  /// results are sorted by number of times entered.
  ///
  /// If multiple words have the same number of entries, they are sorted by recency,
  /// with the most recently entered word being first.
  void enter(String entry) {
    _tree.addWord(entry);
    _hasChanged = true;
  }

  /// Add multiple entries to the engine.
  ///
  /// The engine will now include the contents of `entries` as a search result.
  /// If you enter a word multiple times, it will be prioritized in the search
  /// results, since search results are sorted by number of times entered.
  ///
  /// If multiple words have the same number of entries, they are sorted by recency,
  /// with the most recently entered word being on top.
  void enterList(List<String> entries) {
    for (var x in entries) {
      enter(x);
    }
    _hasChanged = true;
  }

  /// Clear all the entries. The engine is now blank.
  void clearEntries() {
    _tree.root = TrieNode('', false);
    _hasChanged = true;
  }

  /// Get all the entries in a list.
  ///
  /// This is equivalent to getting the suggestions for a blank String. Therefore,
  /// these words will be ordered by number of entrances into the bank. As always,
  /// if two words have the same number of entrances, they are sorted by recency.
  List<String> get allEntries => _tree.suggestions('');

  /// Suggest entries based on the beginning of the string.
  ///
  /// This method returns a List<String>, which contains the suggestions (entries).
  /// These suggestions are ordered by the number of times the suggestion has been
  /// entered.
  ///
  /// If multiple suggestions have the same number of entries, they are sorted by recency,
  /// with the most recently entered suggestion being on top.
  List<String> suggest(String prefix) {
    return _tree.suggestions(prefix);
  }

  /// Returns true if this engine has no entries.
  bool get isEmpty => _tree.root.children.isEmpty;

  /// Returns true if this engine contains `entry`.
  bool contains(String entry) => _tree.search(entry);

  /// Deletes `entry` from the engine if it exists.
  ///
  /// If `entry` is not in the list, it will do nothing.
  void delete(String entry) => _tree.remove(entry);
}


extension AutoCompleteBox on Box {
  /// Gives suggested auto-complete keys from this box, along with corresponding
  /// values. Suggested values are sorted by number of occurrences in this box.
  ///
  /// If all keys are not String, this will instead call the toString() method
  /// of non-String keys and search the results.
  ///
  /// Suggestions are returned in a Map, where:
  /// - The keys are the autocomplete suggestions.
  /// - The values are the corresponding values from this box.
  ///
  /// Recency subsorting does not work for Hive integration.
  Map<dynamic, dynamic> searchKeys(String keyPrefix) {
    var keyList = keys.map((e) => e.toString()).toList();
    var _engineKeys = AutoComplete(bank: keyList);
    var keysuggest = _engineKeys.suggest(keyPrefix);
    var map = toMap();
    map.removeWhere((dynamic key, dynamic val) {
      return !keysuggest.contains(key.toString());
    });
    return map;
  }

  /// Gives suggested auto-complete values from this box, along with corresponding
  /// keys. Suggested values are sorted by number of occurrences in this box.
  ///
  /// If all keys are not String, this will instead call the toString() method
  /// of non-String keys and search the results.
  ///
  /// Suggestions are returned in a Map, where:
  /// - The keys are the correspondent keys to the autocomplete suggestions.
  /// - The values are the autocomplete suggestions.
  ///
  /// Recency subsorting does not work for Hive integration.
  Map<dynamic, dynamic> searchValues(String valuePrefix) {
    var valList = values.map((e) => e.toString()).toList();
    var _engineValues = AutoComplete(bank: valList);
    var valuesuggest = _engineValues.suggest(valuePrefix);
    var map = toMap();
    map.removeWhere((dynamic key, dynamic val) {
      return !valuesuggest.contains(val.toString());
    });
    return map;
  }
}
