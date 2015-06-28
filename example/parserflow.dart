// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library parserflow.example;

import 'package:parserflow/parserflow.dart' as parser;

main() {
  List s = ["9", "8", "+", "9"];
  parser.MatchInfo m = parser.isNum.check(s);
}
