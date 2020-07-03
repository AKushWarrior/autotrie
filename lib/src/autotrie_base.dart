import 'dart:io';
import 'dart:math';

import 'datatree/tree.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

/// Engine for auto-completion of Strings.
///
/// Add entries to build up the suggestion bank. Then, you can use the suggest
/// method to get the auto-completions for the beginning of a String.
class AutoComplete {
  TrieSearchTree _tree;
  bool _changedSincePersist = true;

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
  AutoComplete({@required SortEngine algorithm, List<String> bank}) {
    _tree = TrieSearchTree(algorithm.scoreFunc);
    bank ??= <String>[];
    for (var x in bank) {
      enter(x);
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
    _changedSincePersist = true;
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
    _changedSincePersist = true;
  }

  /// Clear all the entries. The engine is now blank.
  void clearEntries() {
    _tree.root = TrieNode('', false);
    _changedSincePersist = true;
  }

  /// Get all the entries in a list.
  ///
  /// This is NOT sorted. Use [suggest('')] to get all results, sorted.
  List<String> get allEntries => _tree.all.map((e) => e.value);

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
  /// If `entry` is not in the engine, it will do nothing.
  void delete(String entry) => _tree.remove(entry);

  /// Takes a file and writes the entire engine to it. You can then rebuild this
  /// engine at some point in the future.
  Future<void> persist(File file) async {
    if (!_changedSincePersist) {
      return;
    } else {
      var entriesToWrite = _tree.all;
      var sink = file.openWrite();
      sink.writeAll(entriesToWrite, '\n');
      await sink.flush();
      await sink.close();
    }
  }
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
  Map<dynamic, dynamic> searchKeys(String keyPrefix) {
    var keyList = keys.map((e) => e.toString()).toList();
    var _engineKeys = AutoComplete(algorithm: SortEngine.entriesOnly(), bank: keyList);
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
  Map<dynamic, dynamic> searchValues(String valuePrefix) {
    var valList = values.map((e) => e.toString()).toList();
    var _engineValues = AutoComplete(algorithm: SortEngine.entriesOnly(), bank: valList);
    var valuesuggest = _engineValues.suggest(valuePrefix);
    var map = toMap();
    map.removeWhere((dynamic key, dynamic val) {
      return !valuesuggest.contains(val.toString());
    });
    return map;
  }
}

class SortEngine {
  double Function(SortValue element) scoreFunc;

  /// You can manually define a function to score a given [_SortValue] on a
  /// scale of 0 to 1. A [_SortValue] consists of [msToNow], which is how many
  /// ms ago the entry was submitted, and [numEntries], how many times the entry
  /// has been submitted.
  SortEngine.manual(this.scoreFunc);

  /// A simple engine that sorts entries based on how recently they've been
  /// entered. This engine does not use any number-of-entries sorting.
  SortEngine.msOnly() {
    scoreFunc = (SortValue a) => -(a.msToNow.toDouble());
  }

  /// A simple engine that sorts entries based on how many times they've been
  /// entered. This engine does not use any recency sorting.
  SortEngine.entriesOnly() {
    scoreFunc = (SortValue a) => a.numEntries.toDouble();
  }

  /// A complex multi sorting engine with user-defined value curves.
  ///
  /// It sets [maxEntries] as the maximum number of entries; beyond that point, all
  /// numbers of entries will have the same (max) prioritization. You should define
  /// this as the maximum number of repeated entries you think is likely for your
  /// situation.
  ///
  /// It also sets [timeScale] as the maximum time since entry; beyond that point, all
  /// time since entries will have the same (min) prioritization. You should define
  /// this as the oldest entry you think is likely for your situation.
  ///
  /// Both curves follow a logistic pattern, with an exponential period lasting
  /// until their respective max points. The entries curve is traditional (more
  /// entries --> better score) and the time curve is flipped (more time --> worse
  /// score). As noted above, both max points are user defined.
  SortEngine.configMulti(Duration timeScale, int maxEntries, double msWeight, double entryWeight) {
    if (msWeight + entryWeight != 1.0) {
      throw ArgumentError('msWeight + entryWeight must equal 1.');
    }
    scoreFunc = (SortValue a) {
      var msScore = 1/pow(1.5, (1/timeScale.inMilliseconds)*a.msToNow) * msWeight;
      var entryScore = (1 + (-1/pow(1.5, (1/maxEntries)*a.numEntries))) * entryWeight;
      return entryScore + msScore;
    };
  }

  /// A simpler multi sorting engine with predefined value curves.
  ///
  /// It sets 30 as the maximum number of entries; beyond that point, all
  /// numbers of entries will have the same (max) prioritization.
  ///
  /// It also sets ~3 years as the maximum time since entry; beyond that point, all
  /// time since entries will have the same (min) prioritization.
  ///
  /// Both curves follow a logistic pattern, with an exponential period lasting
  /// until their respective max points. The entries curve is traditional (more
  /// entries --> better score) and the time curve is flipped (more time --> worse
  /// score). As noted above, both max points are user defined.
  ///
  /// If you think that you will have significantly more or less than 30 max entries,
  /// or significantly more or less than ~3 years max time since entry, you are
  /// encouraged to use [configMulti].
  SortEngine.simpleMulti(double msWeight, double entryWeight) {
    if (msWeight + entryWeight != 1.0) {
      throw ArgumentError('msWeight + entryWeight must equal 1.');
    }
    scoreFunc = (SortValue a) {
      var msScore = 1/pow(1.5, (1/0x174876E800)*(a.msToNow)) * msWeight;
      var entryScore = (1 + (-1/pow(1.5, (1/30)*a.numEntries))) * entryWeight;
      return entryScore + msScore;
    };
  }
}

class SortValue {
  final int _msSinceEpoch;
  int get msToNow => DateTime.now().millisecondsSinceEpoch - _msSinceEpoch;
  final int numEntries;

  SortValue(this._msSinceEpoch, this.numEntries);
}
