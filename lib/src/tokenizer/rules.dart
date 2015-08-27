part of parserflow;

typedef int RulesMatcher(List data);
typedef void onParseFunc(MatchInfo m);

/**
 * Rules represent one rule of a grammar in the BNF form.
 * A Rules can contains child, have a specific quantifier and a specific matcher
 *
 * Rules implement a basic Top-Down parsing algorithm through `.consume` and `.check`
 */
class Rules implements Clonable<Rules> {
  static final log = new Logger("Rules");
  String name;
  List<Rules> _child = [];
  RulesMatcher _matcher;
  Quantifier quantifier;
  int quantity;
  List<onParseFunc> _onParseEvent;
  var data;
  bool isTerminal = false;

  Rules(this.name, {RulesMatcher matcher, this.quantifier, this.quantity: 1}) : _matcher = matcher {
    if (quantifier == null)
      quantifier = Quantifier.One;
    this._onParseEvent = [];
  }

  Rules addChild(Rules r) {
    _child.add(r);
    return this;
  }

  Rules operator&(Rules r) {
    if (this is And && this.quantifier == Quantifier.One && this.quantity == 1 && !(r is And)) {
      this.addChild(r);
      return this;
    }
    return new And([this, r]);
  }

  Rules operator|(Rules r) {
    if (r is Or) {
      var tmp = r.clone();
      tmp._child.insert(0, this);
      return tmp;
    } else {
      return new Or([this, r]);
    }
  }

  operator<<(var r) {
    if (r is Rules)
      return addChild(r);
    else if (r is List) {
      consume(r);
      return r;
    }
  }

  Rules operator[](var quantifior) {
    var tmp = this.clone();
    if (quantifior is Quantifier) tmp.quantifier = quantifior;
    else if (quantifior is String) {
      switch (quantifior) {
        case "*":
          tmp.quantifier = Quantifier.ZeroOrMore;
          break;
        case "+":
          tmp.quantifier = Quantifier.OneOrMore;
          break;
        case "?":
          tmp.quantifier = Quantifier.OneOrNot;
          break;
      }
    } else if (quantifior is int) {
      tmp.quantifier = Quantifier.NTimes;
      tmp.quantity = quantifior;
    }

    return tmp;
  }

  // TODO : adding exception throw
  List operator>>(List data) {
    this.consume(data);
    return data;
  }

  List get child => _child;

  bool equal(var r) {
    if (this.runtimeType == r.runtimeType && this.name == r.name) {
      return true;
    } else {
      return false;
    }
  }

  bool operator==(var r) {
    return this.equal(r);
  }

  call(var func) {
    //var tmp = this.clone();
    this.onParse.add(func);
    return this;
  }

  List get onParse {
    return this._onParseEvent;
  }

  /**
   * Check if the rule have at least one child
   */
  bool haveChild() => _child.length > 0;

  /**
   * [_checkChild] will iterate on each child of the rules and check if each child match the input data
   */
  MatchInfo _checkChild(List data) {
    MatchInfo counter = new MatchInfo();
    MatchInfo tmp;

    for (Rules r in _child) {
      tmp = r.check(data.sublist(counter.counter));
      if (tmp.match == false) {
        counter.counter = tmp.counter;
        return counter;
      }
      counter << tmp;
      counter.child.add(tmp);
    }
    return counter;
  }


///   [_check] if the input data match the rule
///   Return a MatchInfo object
  MatchInfo _check(List data, var counter, var checkChild, bool addFailInfo) {
    if (_matcher != null) {
      log.finest("${name}: check on ${data}");
      counter = matchQuantifyRules(data, _matcher, quantifier, quantity: this.quantity, from: this)
        ..matchRule = this;
      if (counter.match == false) {
        return counter;
      }
    }

    if (checkChild) {
      var tmp = _checkChild(data.sublist(counter.counter));
      log.finest("Check child result ${tmp}");
      if (tmp.match == false) return tmp;
      counter.child.addAll(tmp.child);
      counter << tmp;
    }
    counter.matchData = data.sublist(counter.start, counter.start+counter.counter);
    return counter;
  }

  /// Parse the input data by using a basic top-down algorithm
  MatchInfo check(var data, {bool checkChild: true, bool ignoreSpace : true, bool addFailInfo : false}) {
    if (data is String) {
      data = new List.from(data.split(''));
    }
    if (ignoreSpace) {
      data.removeWhere((e) => [" ", "\t", "\n"].contains(e));
    }
    MatchInfo counter = new MatchInfo();
    MatchInfo tmp;

    counter.matchRule = new Container()
      ..quantity = this.quantity
      ..quantifier = this.quantifier;

    var i = 0;
    do {
      tmp = _check((data as List).sublist(counter.counter), new MatchInfo(), checkChild, addFailInfo);
      tmp.matchRule = this;
      if (tmp.match || addFailInfo) {
        this._onParseEvent.forEach((f) => f(tmp));
        if (tmp.counter > 0 && !addFailInfo) i++;
        counter << tmp;
        counter.matchData = (counter.matchData == null) ? tmp.matchData: counter.matchData.addAll(tmp.matchData);
        tmp.matchRule = this;
        counter.child.add(tmp);
        if (!tmp.match) break;
      } else {
        break;
      }
    } while(tmp.match && tmp.counter > 0 && continueCheck(i, this.quantifier, this.quantity) && counter.counter < data.length);
    if (counter.child.length == 1)
      counter = counter.child[0];
    if (!matchQuantifier(i, this.quantifier, this.quantity)) {
      counter.counter = MatchInfo.MATCH_FAILED;
    }
    return counter;
  }

  /// Parse the input data by using a basic top-down algorithm
  /// Consume the input data if the rules matches
  List consume(var data, {bool checkChild: true}) {
    if (data is String) {
      data = new List.from(data.split(''));
    }
    MatchInfo counter = check(data, checkChild: checkChild);
    if (counter.match == false)
      return null;
    var ret = data.sublist(0, counter.counter);
    data.removeRange(0, counter.counter);
    return ret;
  }

  /// Search inside the Rules or his child, All the Rules that match the predicate
  List findAll(var predicate, [List ignoreList]) {
    var l = [];
    if (ignoreList != null && ignoreList.contains(this))
      return l;
    if (predicate(this) == true && !l.contains(this)) {
      l.add(this);
      ignoreList.add(this);
    }
    for (var c in this._child) {
      if (predicate(c) == true && !l.contains(c)) {
        if (ignoreList == null || !ignoreList.contains(c))
          l.add(c);
      }
      if (ignoreList != null)
        ignoreList.add(c);
      if (ignoreList == null || !ignoreList.contains(c)) {
        for (var tmp in c.findAll(predicate, ignoreList)) {
          if (!l.contains(tmp)) {
            if (ignoreList != null)
              ignoreList.add(tmp);
            if (ignoreList == null || !ignoreList.contains(tmp))
              l.add(tmp);
          }
        }
      }
    }
    return l;
  }

  /// Search inside the Rules or his child, All the Rules that match the name
  List findAllByName(String name) {
    return findAll((r) => r.name == name, []);
  }

  /// Search inside the Rules or his child, a Rule that match the predicate
  find(var predicate) {
    var r = findAll(predicate, []);
    return (r == null || r.length == 0 ? null : r[0]);
  }

  /// Search inside the Rules or his child, a Rule that match name
  findByName(String name) {
    var r = findAllByName(name);
    return (r == null || r.length == 0 ? null : r[0]);
  }

  String toString({depth: 0}) {
    var s = "[${runtimeType} (${name})] quantifior: ${quantifier}, quantity: ${quantity}, nbChild: ${_child.length}, isTerminal : ${isTerminal}\n";
    for (var r in this._child) {
      s +=(new List.filled(depth, " ")).join();
      if (r != this)
        s += " - " + r.toString(depth: depth+2);
      else
        s += " - [${runtimeType} (${name})] quantifior: ${quantifier}, quantity: ${quantity}, nbChild: ${_child.length}\n";
    }
    return s;
  }


  String ebnfString() {
    return this.data;
  }

  Rules _clone() {
    return new Rules(this.name);
  }

  /// Create a clone of the Rules, that will share child, listener and data
  clone() {
    var t = _clone();
    t.name = this.name;
    t.quantifier = this.quantifier;
    t._matcher = this._matcher;
    t._child = new List.from(this._child);
    t.isTerminal = this.isTerminal;
    t.data = this.data;
    t.onParse.addAll(this._onParseEvent);
    return t;
  }
}