library parserflow.test;

import 'package:test/test.dart';
import 'package:parserflow/parserflow.dart';
import "package:logging/logging.dart";

main() {
  group("Base rules test", () {
    test("IsNum test", () {
      expect(isNum.check("974").match, true);
      expect(isNum.check("+9").match, false);
      expect(isNum.check("9875").counter, 4);
    });
    test("IsDigit test", () {
      expect(isDigit.check("974").match, true);
      expect(isDigit.check("+9").match, false);
      expect(isDigit.check("9875").counter, 1);
    });
    test("IsStr test", () {
      expect(isDigit.check("974").match, true);
      expect(isDigit.check("+9").match, false);
      expect(isDigit.check("9875").counter, 1);
    });
    test("Has test", () {
      expect(has("hello").check("hello").match, true);
      expect(has("hello").check("hellu").match, false);
      expect(has(new RegExp(r'[0-9]+')).check("98745").match, true);
    });
  });
}
