library parserflow.rulesTest;

import 'package:unittest/unittest.dart';
import 'package:parserflow/parserflow.dart';
import "dart:async";
import "dart:io";
import "dart:convert";


void rulesTest() {
  group("Rules test", () {
    test("Simple match, without children", () {
      List s = ["9", "8", "+", "9"];
      MatchInfo m = isNum.check(s);
      expect(m.match, true);
      m = isNum.check(["a", "9"]);
      expect(m.match, false);
    });
    test("Simple match, consume", () {
      List s = ["9", "6", "8", "+", "7"];

      List a = isNum.consume(s);
      print(a);
      expect(s[0], "+");

      MatchInfo m = isMathOperator.check(s);
      expect(m.match, true);
      a = isMathOperator.consume(s);
      a = isNum.consume(s);

      expect(s.length, 0);
    });

    test("Rules combinations", () {
      List base = ["9", "6", "8", "+", "7"];
      List s = new List.from(base);

      Rules r = (isMathOperator | isNum);
      expect(r.name, "Or");
      print("==>>" + r.check(s).toString());
      expect(r.check(s).match, true);
      var a = r.consume(s);
      print(a);
      expect(s[0], "+");
      a = r.consume(s);
      print(a);
      a = r.consume(s);
      print(a);
      s = new List.from(base);

      a = (isNum & isMathOperator).consume(s);
      expect(s[0], "7");
      print(a);
    });
  });
}

main() {
  rulesTest();
}