part of parserflow;

/**
 * NFA will generate the Non Finite Automate from a CNF grammar that will be used be the LR Parser
 */
class NFA {
  List<String> rules;
  List<List<String>> rule = [];
  List<String> nonTerminal = [];
  List<Node> states;
  String startRule;
  List<Node> nfa;
  Set transitionSet = new Set();

  List<Node> createAllTheState(List<List<String>> rules) {
    List<Node> states = [];

    int j = 0;
    for (var r in rules) {
      int i = 1;
      for (var e in r) {
        var newList = new List.from(r);
        newList.insert(i, Node.dot);
        var n = new Node(rule: newList);
        if (!states.contains(n)) {
          n.stateIdx = states.length;
          n.idx = j;
          states.add(n);
        }
        i++;
      }
      j++;
    }
    return states;
  }

  List<Node> getAllRulesWithName(String ruleName) {
    List<Node> clojure = [];
    if (nonTerminal.contains(ruleName)) {
      for (var n in states) {
        if (n.ruleName == ruleName && n.firstSymbol == Node.dot) {
          clojure.add(n);
          if (nonTerminal.contains(n.symbolAfterDot) && n.symbolAfterDot != ruleName) {
            var l = getAllRulesWithName(n.symbolAfterDot);
            if (l.length > 0) clojure.addAll(l);
          }
        }
      }
    }
    return clojure;
  }

  List<Node> _getRuleClojure(Node rule) {
    List<Node> clojure = [];
    clojure.add(rule);
    var l = getAllRulesWithName(rule.symbolAfterDot);
    if (l.length > 0)
      clojure.addAll(l);
    return clojure;
  }

  createStates(String grammars) {
    rules = grammars.split("\n");

    for (var r in rules) {
      r = r.replaceFirst(new RegExp(r'\s*'), '');
      var l = r.split(" ");
      if (l.length == 0 || l[0] == "")
        continue;
      if (!nonTerminal.contains(l[0]))
        nonTerminal.add(l[0]);
      l.removeAt(1);
      if (rule.length == 0)
        startRule = l[0];
      if (startRule == l[0])
        l.add(Node.end);
      rule.add(l);
    }
    states = createAllTheState(rule);
  }

  generatorNFA(String grammars) {
    createStates(grammars);
    _generatorNFA(Node node) {
      if (node.symbolAfterDot == null || node.symbolAfterDot == Node.end) {
        node.clojure = [node.rule];
        if (node.symbolAfterDot == Node.end) {
          transitionSet.add(node.symbolAfterDot);
          node.links[node.symbolAfterDot] = null;
        }
        return node;
      }
      node.clojure = _getRuleClojure(node);
      for (var c in node.clojure) {
        if (c.symbolAfterDot != null && (c.stateIdx+1) < states.length) {
          transitionSet.add(c.symbolAfterDot);
          if (states[c.stateIdx+1].links.length > 0) {
            node.links[c.symbolAfterDot] = states[c.stateIdx+1];
          } else if (node.links[c.symbolAfterDot] != null) {
            states[c.stateIdx+1].parent = node;
            node.links[c.symbolAfterDot].links.addAll( _generatorNFA(states[c.stateIdx+1]).links);
          } else {
            states[c.stateIdx+1].parent = node;
            node.links[c.symbolAfterDot] = _generatorNFA(states[c.stateIdx+1]);
          }
        }
      }
      return node;
    }
    Node ret = _generatorNFA(states[0]);
    var tmp = [];
    for (var n in states) {
      if (n.parent != null || n == states[0]) {
        n.stateIdx = tmp.length;
        tmp.add(n);
      }
    }
    nfa = tmp;
    return tmp;
  }
}

class Node {
  static const String dot = '__DOT__';
  static const String end = '__END__';
  Node parent;
  List<String> rule;
  Map<String, Node> links = {};
  List<Node> clojure = [];
  int idx;
  int stateIdx;

  Node({this.parent, this.rule, this.links}) {
    if (this.links == null) this.links = {};
  }

  bool operator==(Node n) {
    if (n.rule.length != this.rule.length) return false;
    for  (var idx = 0; idx < n.rule.length; idx++) {
      if (n.rule[idx] != this.rule[idx]) return false;
    }
    return true;
  }

  List<String> get afterDot {
    var i = this.dotIdx;
    return rule.sublist(i+1);
  }

  int get dotIdx {
    return rule.indexOf(Node.dot);
  }

  bool isNext(Node n) {
    if (n.rule.length != this.rule.length) return false;
    if (n.dotIdx-1 == this.dotIdx) {
      var i = 0;
      var j = 0;
      for (; i < n.rule.length && j < this.rule.length; i++, j++) {
        if (n.rule[i] == Node.dot)
          i++;
        if (this.rule[j] == Node.dot)
          j++;
        if (n.rule[i] != this.rule[j]) return false;
      }
      return true;
    } else {
      return false;
    }
  }

  String get symbolAfterDot {
    var idx = this.dotIdx;
    return idx >= rule.length-1 ? null : rule[idx+1];
  }

  String get firstSymbol => rule[1];

  String get ruleName => rule[0];

  String toString() {
    var s = " ${rule[0]} ->";
    var sym;
    for (var i = 1; i < rule.length; i++) {
      if (rule[i] == Node.dot)
        sym = "*";
      else if (rule[i] == Node.end)
        sym = "\$";
      else
        sym = rule[i];
      s += " ${sym}";
    }
    s = "[${idx}]".padLeft(4) + s.padLeft(16);
    return s;
  }
}