part of parserflow;

abstract class GrammarGenerator {
  String generateGrammars(Rules r);
}

/**
 * CNFGrammarGenerator will take a set Of rules a will transform it to a string which are the CNF representation of the grammar
 * see [CNF Grammar](https://en.wikipedia.org/wiki/Chomsky_normal_form#Converting_a_grammar_to_Chomsky_normal_form) for more information
 */
class CNFGrammarGenerator {
  var rulesId = [];
  CNFGrammarGenerator();

  String rulesPrettyPrint(Rules r, {String name, String nextName}) {
    var head = "";
    name = name != null ? name : r.name;
    nextName = nextName == null || nextName.length == 0 ? "__EMPTY__" : nextName;
    if (r.quantifier == Quantifier.ZeroOrMore) {
      head += "${name}' -> ${nextName}\n";
      head += "${name}' -> ${name} ${name}''\n";
      head += "${name}'' -> ${name}'\n";
    } else if (r.quantifier == Quantifier.OneOrNot) {
      head += "${name}' -> __EMPTY__\n";
      head += "${name}' -> ${name}\n";
    } else if (r.quantifier == Quantifier.OneOrMore) {
      head += "${name}' -> ${name} ${name}''\n";
      head += "${name}'' -> ${name} ${name}''\n";
      head += "${name}'' -> __EMPTY__\n";
    } else if (r.quantifier == Quantifier.NTimes) {
      var i = r.quantity;
      var tmp = "";
      while (i > 0) {
        tmp += " ${name}";
        i--;
      }
      head += "${name}' -> ${tmp}\n";
    }
    var s = "${name} ->";
    if (r is And && r.child.length > 2) {
      s = "";
      int i = 0;
      var tmpName;
      r.child.forEach((c) {
        tmpName = "${name}${new List.filled(i, "'").join('')}";
        s+= "${tmpName} -> ${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}${i+1 < r.child.length ? " "+tmpName+"'" : ""}\n";
        i++;
      });
      s = s.substring(0, s.length-1);
    } else if (r is And) {
      r.child.forEach((c) {
        s += " ${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}";
      });
    } else if (r is Or) {
      s = "";
      r.child.forEach((c) {
        if (r.name != "${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}")
          s += "${r.name} -> ${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}\n";
      });
      if (s.length > 0)
        s = s.substring(0, s.length-1);
    } else {
      s += " ${r.ebnfString()}";
    }
    if (s == "")
      return head;
    return head + s + "\n";
  }

  _generateRulesPrettyPrint(Rules root, Rules r, Rules next, ParsingTable t, List l, int i, List ignoreList) {
    var all = root.findAllByName(r.name);

    var s = rulesPrettyPrint(r, nextName: (next == null ? '' : "${next.name}${next.quantifier != Quantifier.One ? "'" : ""}"));
    if (!l.contains(s) && s != null && s.length > 0)
      l.add(s);
    ignoreList.add(r);
    for (var idx = 0; idx < r.child.length; ++idx) {
      var c = r.child[idx];
      int length = l.length;
      if (!ignoreList.contains(c)) {
        _generateRulesPrettyPrint(root, c, idx+1 < r.child.length ? r.child[idx+1] : null,t, l, i, ignoreList);
      }
      i += l.length - length;
    }
    return l;
  }

  _getAllRulesUntilTerminal(List rules, String name, int i, var stack) {
    var tmp = rules.where((e) => e["name"] == name);
    for (var r in tmp) {
      if (!stack.contains(r)) {
        r["parent"] = name;
        r["parentId"] = i;
        stack.add(r);
      }
    }
    for (var r in tmp) {
      if (r["isTerminal"] == null && rules.firstWhere((e) => e["name"] == r["value"][0])["isTerminal"] == null) {
        _getAllRulesUntilTerminal(rules, r["value"][0], i, stack);
      }
    }
  }

  _findNullable(List<List<String>> rules) {
    Set<String> nullable = new Set();
    bool nullableFound = true;
    while (nullableFound) {
      nullableFound = false;
      for (var r in rules) {
        if (r.contains("__EMPTY__") && !nullable.contains(r[0])) {
          nullableFound = true;
          nullable.add(r[0]);
        } else if (!r.any((e) => !nullable.contains(e)) && !nullable.contains(r[0])) {
          nullableFound = true;
          nullable.add(r[0]);
        }
      }
    }
    return nullable;
  }

  // Remove
  _removeEmptyRules(List l) {
    Set<String> nullable;
    List<List<String>> rules = [];
    for (var r in l) {
      for (var t in r.split('\n')) {
        var tmp = t.split(' ');
        if (tmp.length > 1)
          rules.add(tmp);
      }
    }
    nullable = _findNullable(rules);
    for (int i = 0; i < rules.length; i++) {
      var r = rules[i];
      var tmp = r.sublist(2);
      for (var n in nullable) {
        if (tmp.contains(n)) {
          var lTmp = r.toList();
          lTmp.removeAt(tmp.indexOf(n)+2);
          //rules.insert(i, )
        }
      }
    }
  }

  // Generate a NFA grammar from a set a Rules
  String generateGrammars(Rules r) {
    var t = new ParsingTable();
    var goal = r;
    var pp = _generateRulesPrettyPrint(goal, goal, null, t, [], 0, []);
    _removeEmptyRules(pp);
    var s = "Goal -> ${r.name}\n";
    pp.forEach((e) => s += e);
    return s;
  }
}