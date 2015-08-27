part of parserflow;

/**
 * Implementation of the LR parsing algorithm
 */
class LrParser extends Parser {
  LrTableGenerator tableGenerator;
  List<Map<String, List<String>>> table;
  List<List<String>> rules;
  Scanner scanner;
  Map<String, Function> actions = {};
  ParseUnit lastUnitParse;
  Rules _rulesSet;

  LrParser({this.tableGenerator, this.table, this.rules}) {
    actions["s"] = shift;
    actions["r"] = reduce;
    actions["g"] = goTo;
  }

  shift(List stack, Scanner scanner) {
    var value;
    if (scanner.finnishSync) {
      value = stack[1];
      stack.insert(0, Node.end);
    } else {
      ParseUnit u = scanner.scanOneSync();

      lastUnitParse = u;
      stack.insert(0, u.value);
      value = u.value;
    }
    if (table[stack[1]][value].length > 1)
      stack.insert(0, int.parse(table[stack[1]][value][stack[1]].substring(1)));
    return table[stack[2]][value][stack[2]][0];
  }

  _createTree(String ruleName) {
    if (_rulesSet != null) {
      var m = new MatchInfo();
      m.matchRule = _rulesSet.findByName(ruleName);
    }
  }

  reduce(List stack, Scanner scanner) {
    var ruleIdx = stack.removeAt(0);
    var lastChar = stack.removeAt(0);
    for (var i = 1; i < tableGenerator.rule[ruleIdx].length; i++) {
      stack.removeAt(0);
      stack.removeAt(0);
    }
    //stack[0] = stack[0]+1;
    stack.insert(0, tableGenerator.rule[ruleIdx][0]);
    goTo(stack, scanner);
    var act = table[stack[0]][lastChar][stack[0]];
    if (act == null && lastChar == Node.end)
      act = table[stack[0]]["__EMPTY__"][stack[0]];
    stack.insert(0, lastChar);
    if (act.length > 1)
      stack.insert(0, int.parse(act.substring(1)));
    return act[0];
  }

  goTo(List stack, Scanner scanner) {
    var rule = stack[0];
    var state = stack[1];
    var act = table[state][rule][state];
    stack.insert(0, int.parse(act.substring(1)));
  }

  step(List stack, Scanner scanner, {String action}) {
    if (action == null)
      return shift(stack, scanner);
    return actions[action](stack, scanner);
  }

  parse(var input, [Rules r]) {
    _rulesSet = r;
    if (table == null || rules == null) {
      if (tableGenerator == null) {
        throw new Exception("LrParser error : no table or tableGenerator provided");
      } else {
        table = tableGenerator.generateTable();
      }
    }
    var stack = [0];
    scanner = new Scanner.fromStringSync(input);
    var act;
    try {
      while (!scanner.finnishSync || stack.length > 2) {
        act = step(stack, scanner, action: act);
        if (act == "a") {
          return ;
        }
      }
    } catch (e, stackTrace) {
      print("Parsing error: error at char. [${lastUnitParse.inlinePos}] at line [${lastUnitParse.line}]\n${stackTrace}");
      return ;
    }
  }
}