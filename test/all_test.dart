// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library parserflow.test;

import 'package:unittest/unittest.dart';
import 'package:parserflow/parserflow.dart';
import "scanner_test.dart";
import "rules_test.dart";
import "package:logging/logging.dart";

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.loggerName}: ${rec.message}');
  });

  scannerTest();
  rulesTest();
}
