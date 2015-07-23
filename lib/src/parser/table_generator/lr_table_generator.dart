part of parserflow;

class LrTableGenerator extends TableGenerator {
  var rulesId = [];
  var _it = 0;
  LrTableGenerator();

  List treeToList(Rules r) {
    var l = [];

  }

  List _rules(Rules r, {name}) {
    var l = [];
    name = name != null ? name : r.name;
    if (r.quantifier == Quantifier.ZeroOrMore) {
      l.add({"name": name+"'", "value" : ["EMPTY"], "isTerminal": true});
      l.add({"name": name+"'", "value" : [name, name+"'"]});
    } else if (r.quantifier == Quantifier.OneOrNot) {
      l.add({"name": name+"'", "value" : ["EMPTY"], "isTerminal": true});
      l.add({"name": name+"'", "value" : [name]});
    } else if (r.quantifier == Quantifier.OneOrMore) {
      l.add({"name": name+"'", "value" : ["EMPTY"], "isTerminal": true});
      l.add({"name": name+"'", "value" : [name, name+"'"]});
      l.add({"name": name+"''", "value" : [name, name+"'"]});
    } else if (r.quantifier == Quantifier.NTimes) {
      var i = r.quantity;
      var tmp = [];
      while (i > 0) {
        tmp.add(name);
        i--;
      }
      l.add({"name": name+"'", "value" : tmp});
    }
    var s = "${name} ::=";
    var tmp = [];
    if (r is And) {
      r.child.forEach((c) => tmp.add("${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}${c.quantifier == Quantifier.OneOrMore ? "'" : ""}"));
      l.add({"name": name, "value": tmp});
    } else if (r is Or) {
      r.child.forEach((c) => l.add({"name": name, "value": ["${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}"]}));
    } else {
      tmp.add("TERMINAL");
      l.add({"name": name, "value": tmp, "isTerminal": true});
    }
    return l;
  }

  String rulesPrettyPrint(Rules r, {name}) {
    var head = "";
    name = name != null ? name : r.name;
    if (r.quantifier == Quantifier.ZeroOrMore) {
      head += "${name}' ::= EMPTY\n";
      head += "${name}' ::= ${name} ${name}'\n";
    } else if (r.quantifier == Quantifier.OneOrNot) {
      head += "${name}' ::= EMPTY\n";
      head += "${name}' ::= ${name}\n";
    } else if (r.quantifier == Quantifier.OneOrMore) {
      head += "${name}' ::= EMPTY\n";
      head += "${name}' ::= ${name} ${name}'\n";
      head += "${name}'' ::= ${name} ${name}'\n";
    } else if (r.quantifier == Quantifier.NTimes) {
      var i = r.quantity;
      var tmp = "";
      while (i > 0) {
        tmp += " ${name}";
        i--;
      }
      head += "${name}' ::= ${tmp}\n";
    }
    var s = "${name} ::=";
    if (r is And) {
      r.child.forEach((c) => s+= " ${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}");
    } else if (r is Or) {
      s = "";
      r.child.forEach((c) => s += "${r.name} ::= ${c.name}${c.quantifier != Quantifier.One || c.quantity != 1 ? "'": ""}\n");
      s = s.substring(0, s.length-1);
    } else {
      s += " ${r.data}";
    }
    return head + s;
  }

  _generateSimplifyRules(Rules root, Rules r, ParsingTable t, List l, int i) {
    var all = root.findAllByName(r.name);

    var s = _rules(r);
    for (var tmp in s) {
      if (!l.any((e)=> e["name"].toString() == tmp["name"].toString() && e["value"].toString() == tmp["value"].toString())) {
        tmp["id"] = i;
        l.add(tmp);
        i++;
      }
    }
    for (var c in r.child) {
      int length = l.length;
      _generateSimplifyRules(root, c, t, l, i);
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

  _generateNFA(List rules, var stacks, var parent) {
    var node = {};
    var stack = [];
    stacks.forEach((r) {
      if (r["idx"] < r["value"].length)
        _getAllRulesUntilTerminal(rules, r["value"][r["idx"]], r["id"], stack);
    });
    var table = {};
    for (var r in stack) {
        if (table[r["value"][0]] == null)
          table[r["value"][0]] = [];
        table[r["value"][0]].add(new Map.from(r) ..["idx"] = 0);
    }
    for (var r in stacks) {
      if (r["idx"] >= r["value"].length) {
        if (table["__reduce__"] == null)
          table["__reduce__"] = [];
        table["__reduce__"].add(r);
        continue;
      }
      if (table[r["value"][r["idx"]]] == null)
        table[r["value"][r["idx"]]] = [];
      table[r["value"][r["idx"]]].add(r);
    }
    for (var s in stack) {
      if (!stacks.any((e) => e["id"] == s["id"]))
        stacks.add(s);
    }
    table.remove("TERMINAL");
    table.forEach((key, value) {
      value.forEach((v) {
        v["idx"]++;
        if (v["idx"] < v["value"].length && v["value"][v["idx"]] == v["name"]) {
          v["idx"]++;
          v["loop"] = true;
        }
      });
      value.removeWhere((e) => e["idx"] < e["value"].length && e["value"][e["idx"]] == key);
      if (key != "EMPTY" && key != "__reduce__")
        node[key] = _generateNFA(rules, value, key);
      else
        node["__reduce__"] = value[0]["parent"] == null ? {"rule": "__accept__", "id": 0} : {"rule": value[0]["parent"], "id": value[0]["id"]};
      //print("${_it-1}. ${key} -> ${_it}\n   ${value}");
      _it++;
    });
    return node;
  }

  _createTable(List rules, var node, int stateIdx, Map assign, Map actionTable, Map gotoTable, String prev) {
    print("stateIn: ${stateIdx}");
    initState(int state) {
      actionTable[state] = {};
      rules.forEach((e) {
        if (e["isTerminal"] != null && e["value"][0] != "EMPTY")
          actionTable[state][e["name"]] = "  ";
      });
      actionTable[state]["\$"];
    }
    emptyRow(Map row) {
      bool check = true;
      row.forEach((k, v) {
        print("[${v}] != [  ] ? ${v != "  "}");
        if (v != "  ")
          check = false;
      });
      return check;
    }
    initState(stateIdx);
    for (var key in node.keys) {
      var value = node[key];
      bool isTerminal = rules.any((e) => e["name"] == key && e["isTerminal"] != null);
      if (key == "__reduce__") {
        print("reduce in state ${stateIdx}");
        actionTable[stateIdx].forEach((k, v) {
          actionTable[stateIdx][k] = actionTable[stateIdx][k] == "  " ? "r${value["id"]}" : actionTable[stateIdx][k];
        });
      } else if (isTerminal) {
        print("key: ${key} isTerminal in state ${stateIdx}");
        actionTable[stateIdx][key] = "s${stateIdx+1}";
        stateIdx = _createTable(rules, value, stateIdx+1, assign, actionTable, gotoTable, key);
        stateIdx += 1;
        initState(stateIdx);
      } else {
        print("key: ${key} is not Terminal in state ${stateIdx}");
        stateIdx = _createTable(rules, value, stateIdx, assign, actionTable, gotoTable, key);
        //initState(state);
      }
      print("state: ${stateIdx}");
    }
    if (emptyRow(actionTable[stateIdx])) {
      print(actionTable[stateIdx]);
      --stateIdx;
    }
    print("stateOut: ${stateIdx}");
    return stateIdx;
  }

  ParsingTable generateTable(Rules r) {
    var t = new ParsingTable();
    var ret = _generateSimplifyRules(r, r, t, [], 0);
    ret.forEach((s) {
      s["idx"] = 0;
      print(s);
      rulesId.add(s);
    });
    var m = _generateNFA(ret, [ret[0]], "root");
    print("\n========");
    print(m);

    var table = {};
    var gotoTable = {};
    _createTable(ret, m, 0, {}, table, gotoTable, "");
    var s = "  ";
    print(ret);
    ret.forEach((e) {
      if (e["isTerminal"] != null && e["value"][0] != "EMPTY")
        s += " ${e["name"]}";
    });
    s += " \$";
    print(s);
    s = "";
    table.forEach((key, value) {
      s += "${key}.";
      value.forEach((k, v) {
        s += " [${v}]";
      });
      s += "\n";
    });
    print(s);
  }
}