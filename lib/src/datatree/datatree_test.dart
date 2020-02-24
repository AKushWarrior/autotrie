import 'tree.dart';

void main() {
  var tree = TrieSearchTree();

  tree.addWord('more'); //enter more thrice
  tree.addWord('more');
  tree.addWord('more');

  tree.addWord('moody'); //enter moody twice
  tree.addWord('moody');

  tree.addWord('morose'); //enter scattered words (with mo)
  tree.addWord('morty');
  tree.addWord('moment');
  tree.addWord('momentum');

  tree.addWord('sorose'); //enter scattered words (without mo)
  tree.addWord('sorty');

  tree.remove('morose');

  print(tree.suggestions('mo')); // [more, moody, morty, moment, momentum]
}