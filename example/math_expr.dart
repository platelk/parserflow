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
    //var signe = m.child[m.child.length - 2].matchData;
    var num = m.matchData.join();
    if (buffer.length > 1) {
      buffer.add(buffer.removeLast()(buffer.removeLast(), int.parse(num)));
    }
    else
      buffer.add(int.parse(num));
  } else if (m.matchRule.name == "op") {
    if (m.matchData[0] == "+") buffer.add((a, b) => a + b);
    if (m.matchData[0] == "-") buffer.add((a, b) => a - b);
    if (m.matchData[0] == "*") buffer.add((a, b) => a * b);
    if (m.matchData[0] == "/") buffer.add((a, b) => a / b);
  }
}

var opTable = {
  "+": (a, b) => a+b,
  "-": (a, b) => a-b,
  "*": (a, b) => a*b,
  "/": (a, b) => a/b
};

void factorHook(MatchInfo i) {
  if (i.get("number") != null) {
    i["value"] = i.get("number")["value"];
  } else if (i.get("factor") != null) {
    var tmp = i.get("factor");
    i["value"] = opTable[tmp.get("high_op", rec: true)["op"]](tmp.get("number", rec: true)["value"], tmp.get("number")["value"]);
  }
}

void resolveExpr(MatchInfo i) {
  var a = i.get("factor")["value"];
  for (var e in i.getAll("low_exp", rec: true)) {
    var b = e.get("factor")["value"];
    var o = e.get("op")["op"];
    a = opTable[o](a, b);
  }
  i["res"] = a;
}

main() {
  var number = (isNum)..name = "number"; // Define rule name 'number'
  number.onParse.add((i) {  // apply a function to be call every time a 'number' is match
    i["value"] = int.parse(i.matchData.join()); // matchData is of type List, so i join to recreate the string
  });

  var factor_op = (hasRegExp(r"[ \* | \/ | % ]")..name = "high_op")((i) => i["op"] = i.matchData.join()); // you can also use the "()" operator to directly pass a function (or 'hook')
  var op = (hasRegExp(r"[-|+]")..name = "op")((i) => i["op"] = i.matchData.join());

  var factor = (((number & factor_op & number)..name = "factor") | number)..name = "factor";
  factor.onParse.add(factorHook);

  var expr = (factor & ((op & factor)..name = "low_exp")["*"])(resolveExpr);
  var input = "2*3-4*2";
  var res = expr.check(input);
  print("res : ${res.data["res"]}");
  //print("${input} = ${visitChild(tree, [])[0]}");
}