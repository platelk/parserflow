library parserflow.example;

import 'package:parserflow/parserflow.dart';

visitChild(List<MatchInfo> l, var buffer) {
  for (var m in l) {
    if (m is List)
      visitChild(m, buffer);
    else {
      visitNode(m, buffer);
    }
  }
  return buffer;
}

int visitNode(MatchInfo m, buffer) {
  if (m.matchRule.name == "number") {
    var signe = m.child[m.child.length - 2].matchData;
    var num = m.child[m.child.length - 1].matchData.join();
    if (buffer.length > 1) {
      buffer.add(buffer.removeLast()(buffer.removeLast(), int.parse(num)));
    }
    else
      buffer.add(int.parse(num));
  } else if (m.matchRule.name == "op") {
    if (m.matchData[0] == "+") buffer.add((a, b) => a + b);
    if (m.matchData[0] == "-") buffer.add((a, b) => a - b);
  }
}

main() {
  var number = (has("-")["*"] & isNum)..name = "number";
  var op = hasRegExp(r'[+|-]')..name = "op";

  var expr = number & (op & number)["*"];

  var input = "968 + 2 - 20";
  var res = expr.check(input);
  var tree = res.matchTree();

  print(tree);
  print("${input} = ${visitChild(tree, [])[0]}");
}