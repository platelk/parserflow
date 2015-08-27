part of parserflow;

/**
 * This class will allow the generation of the LR Parsing table needed be the LR Parsing algorithm
 *
 * It will require the NFA Generated from the CNF Grammar
 */
class LrTableGenerator extends TableGenerator {
  List<String> rules;
  List<List<String>> rule = [];
  List<String> nonTerminal = [];
  List<Node> states;
  String startRule;
  List<Node> nfa;
  Set transitionSet = new Set();
  NFA nfaRepresentation;

  LrTableGenerator(NFA this.nfaRepresentation) {
    rules = nfaRepresentation.rules.toList();
    rule = nfaRepresentation.rule.toList();
    nonTerminal = nfaRepresentation.nonTerminal.toList();
    states = nfaRepresentation.states.toList();
    startRule = nfaRepresentation.startRule;
    nfa = nfaRepresentation.nfa.toList();
    transitionSet = nfaRepresentation.transitionSet.toSet();
  }

  List<Map<String, List<String>>> generateTable({List<Node> nfa}) {
    if (nfa == null)
      nfa = this.nfa;
    List<Map<String, List<String>>> table = new List(nfa.length);
    var i = 0;
    for (var n in nfa) {
      table[i] = new Map.fromIterable(transitionSet, key: (k) => k, value: (v) => new List(nfa.length));
      if (n.links.length == 0) {
        transitionSet.forEach((e) {
          if (!nonTerminal.contains(e) || n.dotIdx == n.rule.length-1) {
            table[i][e][i] = "r${n.idx}";
          }
        });
      } else {
        n.links.forEach((k, v) {
          if (n.dotIdx == n.rule.length-1) {
            transitionSet.forEach((e) {
              if (!nonTerminal.contains(e) || n.dotIdx == n.rule.length-1) {
                table[i][e][i] = "r${n.idx}";
              }
            });
          } else if (nonTerminal.contains(k)) {
            table[i][k][i] = 'g${v.stateIdx == i ? v.stateIdx+1 : v.stateIdx}';
          } else if (k == Node.end){
            table[i][k][i] = 'a';
          } else {
            table[i][k][i] = 's${v.stateIdx}';
          }
        });
      }
      i++;
    }
    return table;
  }

  printTable(List<Map<String, List<String>>> table, {int startPad: 24, int basePad: 4, int linePad: 15}) {
    var s = " ".padLeft(startPad);
    for (var t in transitionSet) {
      s+= "${t == Node.end ? "\$" : t}".padLeft(basePad);
    }
    print(s);
    s = "";
    var i = 0;
    table.forEach((e) {
      s = nfa[i].toString().padLeft(linePad);
      s += "${i}.".padLeft(basePad);
      for (var t in  transitionSet) {
        var r = table[i][t][i];
        s += "${r == null ? "": r}".padLeft(basePad);
      }
      print(s);
      i++;
    });
  }
}