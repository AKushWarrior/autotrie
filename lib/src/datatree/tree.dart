part of '../autotrie_base.dart';

class _TrieSearchTree {
  TrieNode root;
  double Function(SortValue e) sort;

  _TrieSearchTree (this.sort) {
    root = TrieNode('', false);
    root.children = <TrieNode>[];
  }

  void addWord (String word) {
    var base = root;

    //Iterate through string and add/progress through nodes.
    for (var i = 0; i<word.length; i++) {
      var x = TrieNode(word[i], false);
      if (!base.children.contains(x)) {
        // x is added to base.children
        base.children.add(x);
      } else {
        // x points to base.children version
        x = base.children.where((e) => e==x).first;
      }
      if (i == word.length-1) {
        x.lastInsert = DateTime.now().millisecondsSinceEpoch;
        x.hits++;
      }
      base = x;
    }
  }

  void addWordWithParams (String word, int hits, int lastInsert) {
    var base = root;

    //Iterate through string and add/progress through nodes.
    for (var i = 0; i<word.length; i++) {
      var x = TrieNode(word[i], false);
      if (!base.children.contains(x)) {
        // x is added to base.children
        base.children.add(x);
      } else {
        // x points to base.children version
        x = base.children.where((e) => e==x).first;
      }
      if (i == word.length-1) {
        x.lastInsert = lastInsert;
        x.hits = hits;
      }
      base = x;
    }
  }

  List<TrieString> get all {
    var base = root;
    if (base.children == <TrieNode>[] && base.hits > 0) return [];
    var returner = <TrieString>[];
    _suggestRec(base, '', returner);
    return returner;
  }

  List<String> suggestions (String prefix) {
    var base = root;
    for (var i = 0; i<prefix.length; i++) {
      var x = TrieNode(prefix[i], false);
      if (base.children.contains(x)) {
        base = base.children[base.children.indexOf(x)];
      } else {
        return [];
      }
    }
    if (base.children == <TrieNode>[] && base.hits > 0) return [prefix];
    var returner = <TrieString>[];
    _suggestRec(base, prefix, returner);

    returner.sort((TrieString a, TrieString b) {
      var sortA = sort(SortValue(a.lastInsert, a.hits));
      var sortB = sort(SortValue(b.lastInsert, b.hits));

      if (sortA < sortB) {
        return 1;
      } else if (sortA == sortB) {
        return 0;
      } else {
        return -1;
      }
    });
    return returner.map((e) => e.value).toList();
  }

  void _suggestRec (TrieNode node, String word, List<TrieString> returner) {
    if (node.hits > 0) returner.add(TrieString(word, node.hits, node.lastInsert));
    for (var n in node.children) {
      _suggestRec(n, word + n.value, returner);
    }
  }

  bool search (String word) {
    var base = root;
    for (var i = 0; i < word.length; i++) {
      var x = TrieNode(word[i], false);
      if (!base.children.contains(x)) return false;
      base = base.children[base.children.indexOf(x)];
    }
    return true;
  }

  void remove (String word) {
    if (root.children.isEmpty) {
      return;
    } else if (!search(word)) {
      return;
    }
    _delete(root, word, 0);
  }

  bool _delete (TrieNode cur, String word, int index) {
    if (index == word.length) {
      return cur.children.isEmpty;
    }
    var ch = word[index];
    var next = cur.children[cur.children.indexOf(TrieNode(ch, index == word.length-1))];
    if (next == null) {
      return false;
    }
    var shouldDeleteNode = _delete(next, word, index + 1) && (!(next.hits>0) || index == word.length -1);

    if (shouldDeleteNode) {
      cur.children.remove(next);
      return cur.children.isEmpty;
    }
    return false;
  }
}

class TrieString {
  String value;
  int hits;
  int lastInsert;

  TrieString(String value, int hits, int insert) {
    this.value = value;
    this.hits = hits;
    lastInsert = insert;
  }

  @override
  String toString() {
    return '$value | $hits | $lastInsert';
  }
}

class TrieNode {
  String value;
  List<TrieNode> children;
  int lastInsert;
  int hits = 0;

  TrieNode(String value, bool isEnd) {
    this.value = value;
    children = <TrieNode>[];
  }

  @override
  bool operator ==(other) {
    return value == other.value;
  }
}