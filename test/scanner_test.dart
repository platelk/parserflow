library parserflow.scannerTest;

import 'package:unittest/unittest.dart';
import 'package:parserflow/parserflow.dart';
import "dart:async";
import "dart:io";
import "dart:convert";


void scannerTest() {
  Scanner scanner;
  StreamController<String> sc;

  group('Test on scanner', () {
    setUp(() {
      var s = new Stream.fromIterable(["t", "e", "s", "t", "p"]);
      var b = s.asBroadcastStream();
      scanner = new Scanner<String>(b);
    });

    test('scanOne()', () async {
        ParseUnit<String> p = await scanner.scanOne();
        expect(p.value, "t");
        p = await scanner.scanOne();
        expect(p.value, "e");
        p = await scanner.scanOne();
        expect(p.value, "s");
    });
    test('scan()', () async {
      var l = ["t", "e", "s", "t"];
      var i = 0;
      scanner.scan().listen((ParseUnit<String> p) {
        expect(p.value, l[i]);
        i++;
      });
    });
    test("scanOne() on file", () async {

        var s = new File("test/ressources/simple_string.txt").openRead();
        ASCII.decodeStream(s).then((String text) async {
          var ss = new Stream.fromIterable(["t", "e", "s", "t", "p"]);
          var b = ss.asBroadcastStream();
          scanner = new Scanner<String>(b);

          ParseUnit<String> p = await scanner.scanOne();
          expect(p.value, "t");
          p = await scanner.scanOne();
          expect(p.value, "e");
          p = await scanner.scanOne();
          expect(p.value, "s");
        });
    });
  });
}

main() {
  scannerTest();
}