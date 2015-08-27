// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The parserflow library.
///
/// This is an awesome library. More dartdocs go here.
library parserflow;

import "dart:collection";
import "dart:async";
import "package:logging/logging.dart";

import "src/tools/tools.dart";

part "src/scanner/parse_unit.dart";
part "src/scanner/scanner.dart";
part "src/scanner/scanner_conf.dart";

part "src/tokenizer/rules.dart";
part "src/tokenizer/quantifier.dart";
part "src/tokenizer/matcher.dart";

part "src/tokenizer/base_rules/and_or_rules.dart";
part "src/tokenizer/base_rules/is_num_rules.dart";
part "src/tokenizer/base_rules/is_operator.dart";
part "src/tokenizer/base_rules/is_string_rules.dart";

part "src/parser/table_generator/table_generator.dart";
part "src/parser/table_generator/lr_table_generator.dart";
part "src/parser/table_generator/nfa_generator.dart";
part "src/parser/table_generator/grammars.dart";
part "src/parser/lr_parser.dart";
part "src/parser/parser.dart";