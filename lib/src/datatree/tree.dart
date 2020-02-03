class TrieSearchTree {
  TrieNode root;
  TrieSearchTree () {
    root = TrieNode('', false);
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
      if (i == word.length-1) {
        x.isEnd = true;
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
    if (base.children == <TrieNode>[] && base.isEnd) return [prefix];
    var returner = <TrieString>[];
    _suggestRec(base, prefix, returner);
    returner.sort((TrieString a, TrieString b) {
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
    if (node.isEnd) returner.add(TrieString(word, node.hits));
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
      if (!cur.isEnd) {
        return false;
      }
      cur.isEnd = false;
      return cur.children.isEmpty;
    }
    var ch = word[index];
    var node = cur.children[cur.children.indexOf(TrieNode(ch, false))];
    if (node == null) {
      return false;
    }
    var shouldDeleteCurrentNode = _delete(node, word, index + 1) && !node.isEnd;

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

  TrieString(String value, int hits) {
    this.value = value;
    this.hits = hits;
  }
}

class TrieNode {
  String value;
  List<TrieNode> children;
  bool isEnd;
  int hits = 0;

  TrieNode(String value, bool isEnd) {
    this.value = value;
    this.isEnd = isEnd;
    children = <TrieNode>[];
  }

  @override
  bool operator ==(other) {
    return value == other.value;
  }
}