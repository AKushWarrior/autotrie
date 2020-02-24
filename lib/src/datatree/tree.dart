import 'package:collection/collection.dart' as collect;

class TrieSearchTree {
  TrieNode root;

  TrieSearchTree () {
    root = TrieNode('', false);
    root.children = <TrieNode>[];
  }

  void addWord (String word) {
    var base = root;
    for (var i = 0; i<word.length; i++) {
      var x = TrieNode(word[i], false);
      if (!base.children.contains(x)) {
        base.children.add(x);
      } else {
        x = base.children[base.children.indexOf(x)];
      }
      x.lastInsert = DateTime.now().microsecondsSinceEpoch;
      if (i == word.length-1) {
        x.hits++;
      }
      base = x;
    }
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
      if (a.lastInsert < b.lastInsert) {
        return 1;
      } else if (a.lastInsert == b.lastInsert) {
        return 0;
      } else {
        return -1;
      }
    });
    returner.mergeSort((TrieString a, TrieString b) {
      if (a.hits < b.hits) {
        return 1;
      } else if (a.hits == b.hits) {
        return 0;
      } else {
        return -1;
      }
    });
    return List.generate(returner.length, (int i) {return returner[i].value;});
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
      if (!base.children.contains(TrieNode(word[i], false))) return false;
      base = base.children[base.children.indexOf(x)];
    }
    return true;
  }

  void remove (String word) {
    if (root.children.isEmpty) {
      return;
    } else if (!search(word)) return;
    _delete(root, word, 0);
  }

  bool _delete (TrieNode cur, String word, int index) {
    if (index == word.length) {
      if (!(cur.hits > 0)) {
        return false;
      }
      return cur.children.isEmpty;
    }
    var ch = word[index];
    var node = cur.children[cur.children.indexOf(TrieNode(ch, false))];
    if (node == null) {
      return false;
    }
    var shouldDeleteCurrentNode = _delete(node, word, index + 1) && !(node.hits>0);

    if (shouldDeleteCurrentNode) {
      cur.children.remove(TrieNode(ch, false));
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

extension Collect<T> on List<T> {
  void mergeSort (int Function(T a, T b) compare) {
    collect.mergeSort(this, compare:compare);
  }
}