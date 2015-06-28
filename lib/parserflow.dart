// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The parserflow library.
///
/// This is an awesome library. More dartdocs go here.
library parserflow;

import "dart:collection";
import "dart:async";
import "package:logging/logging.dart";

// TODO: Export any libraries intended for clients of this package.

part "src/scanner/parse_unit.dart";
part "src/scanner/scanner.dart";
part "src/scanner/scanner_conf.dart";

part "src/tokenizer/rules.dart";
part "src/tokenizer/quantifier.dart";
part "src/tokenizer/matcher.dart";

part "src/tokenizer/base_rules/and_or_rules.dart";
part "src/tokenizer/base_rules/is_num_rules.dart";
part "src/tokenizer/base_rules/is_operator.dart";