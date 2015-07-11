part of parserflow;

typedef int RulesMatcher(List data);

class Rules implements Clonable<Rules> {
  static final log = new Logger("Rules");
  String name;
  List<Rules> _child = [];
  RulesMatcher _matcher;
  Quantifier quantifier;
  int quantity;

  Rules(this.name, {RulesMatcher matcher, this.quantifier, this.quantity: 1}) : _matcher = matcher {
    if (quantifier == null)
      quantifier = Quantifier.One;
  }

  Rules addChild(Rules r) {
    _child.add(r);
    return this;
  }

  Rules operator&(Rules r) {
    if (r is And) {
      r._child.add(this);
      return r;
    } else {
      return new And([this, r]);
    }
  }

  Rules operator|(Rules r) {
    if (r is Or) {
      r._child.add(this);
      return r;
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

  /**
   * Check if the rule have at least one child
   */
  bool haveChild() => _child.isEmpty;

  /**
   * [_checkChild] will iterate on each child of the rules and check if each child match the input data
   */
  MatchInfo _checkChild(List data) {
    MatchInfo counter = new MatchInfo();
    MatchInfo tmp;

    for (Rules r in _child) {
      tmp = r.check(data.sublist(counter.counter));
      if (tmp.match == false)
        return tmp;
      counter << tmp;
      counter.child.add(tmp);
    }
    return counter;
  }


///   [_check] if the input data match the rule
///   Return a MatchInfo object
  MatchInfo _check(List data) {
    log.finest("${name}: check on ${data}");
    return matchQuantifyRules(data, _matcher, quantifier, quantity: this.quantity)
            ..matchRule = this;
  }

  ///
  MatchInfo check(List data, {bool checkChild: true}) {
    MatchInfo counter = new MatchInfo();
    MatchInfo tmp;

    counter.matchRule = this;

    if (_matcher != null) {
      counter = _check(data);
      if (counter.match == false)
        return counter;
    }

    if (checkChild) {
      tmp = _checkChild(data.sublist(counter.counter));
      log.finest("Check child result ${tmp}");
      if (tmp.match == false) return tmp;
      counter.child.addAll(tmp.child);
      counter << tmp;
    }
    counter.matchData = data.sublist(counter.start, counter.start+counter.counter);
    return counter;
  }

  /// Consume the input data if the rules matches
  List consume(List data, {bool checkChild: true}) {
    MatchInfo counter = check(data, checkChild: checkChild);
    if (counter.match == false)
      return null;
    var ret = data.sublist(0, counter.counter);
    data.removeRange(0, counter.counter);
    return ret;
  }

  String toString() {
    var s = "[Rules (${this.name})] quantifior: ${this.quantifier}, quantity: ${this.quantity}, nbChild: ${this._child.length}\n";
    for (var r in this._child) {
      s += " - " + r.toString();
    }
    return s;
  }

  Rules _clone() {
    return new Rules(this.name);
  }

  clone() {
    var t = _clone();
    t.name = this.name;
    t.quantifier = this.quantifier;
    t._matcher = this._matcher;
    t._child = this._child;
    return t;
  }
}