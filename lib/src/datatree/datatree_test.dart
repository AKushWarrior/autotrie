import 'dart:io';

import 'package:autotrie/autotrie.dart';
import 'tree.dart';

void main() {
  var tree = TrieSearchTree(SortEngine.configMulti(Duration(seconds:30), 5, 0.25, 0.75).scoreFunc);

  tree.addWord('more'); //enter more thrice
  tree.addWord('more');
  tree.addWord('more');
  sleep(Duration(seconds: 1));

  tree.addWord('moody'); //enter moody twice
  tree.addWord('moody');
  sleep(Duration(seconds: 1));

  tree.addWord('morose'); //enter scattered words (with mo)
  sleep(Duration(seconds: 1));
  tree.addWord('morty');
  sleep(Duration(seconds: 1));
  tree.addWord('moment');
  sleep(Duration(seconds: 1));
  tree.addWord('momentum');
  sleep(Duration(seconds: 1));

  tree.addWord('sorose'); //enter scattered words (without mo)
  sleep(Duration(seconds: 1));
  tree.addWord('sorty');
  sleep(Duration(seconds: 1));

  //tree.remove('morose');

  print(tree.suggestions('')); // [more, moody, morty, moment, momentum]
}