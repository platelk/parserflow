library parserflow.example;

import 'package:parserflow/parserflow.dart';

var opTable = {
  "+": (a, b) => a+b,
  "-": (a, b) => a-b,
  "*": (a, b) => a*b,
  "/": (a, b) => a/b
};

void factorHook(MatchInfo i) {
  if (i.get("number") != null) {
    i["value"] = i.get("number")["value"];
  } else if (i.get("factor_calc") != null) {
    var tmp = i.get("factor_calc");
    i["value"] = opTable[tmp.get("high_op", rec: true)["op"]](tmp.child[0]["value"], tmp.child[2]["value"]);
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

  var factor = (((number & factor_op & number)..name = "factor_calc") | number)..name = "factor";
  factor.onParse.add(factorHook);

  var expr = (factor & ((op & factor)..name = "low_exp")["*"])(resolveExpr);
  var l = new LrTableGenerator().generateTable(expr);

  var input = "2*3+2";
  print(expr);
  var res = expr.check(input);
  print(res.matchTree());
  print("res : ${res.data["res"]}");
}