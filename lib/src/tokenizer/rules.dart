part of parserflow;

typedef int RulesMatcher(List data);

class Rules implements Clonable<Rules> {
  static final log = new Logger("Rules");
  String name;
  List<Rules> _child = [];
  RulesMatcher _matcher;
  Quantifier quantifier;
  int quantity;
  StreamController<MatchInfo> _onParseEvent;

  Rules(this.name, {RulesMatcher matcher, this.quantifier, this.quantity: 1}) : _matcher = matcher {
    if (quantifier == null)
      quantifier = Quantifier.One;
    this._onParseEvent = new StreamController.broadcast();
  }

  Rules addChild(Rules r) {
    _child.add(r);
    return this;
  }

  Rules operator&(Rules r) {
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

  get onParse {
    return this._onParseEvent.stream;
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
  MatchInfo _check(List data, var counter, var checkChild) {
    if (_matcher != null) {
      log.finest("${name}: check on ${data}");
      counter = matchQuantifyRules(data, _matcher, quantifier, quantity: this.quantity)
        ..matchRule = this;
      if (counter.match == false) {
        return counter;
      }
      _onParseEvent.add(counter);
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

  ///
  MatchInfo check(var data, {bool checkChild: true, bool ignoreSpace : true}) {
    if (data is String) {
      data = new List.from(data.split(''));
    }
    if (ignoreSpace) {
      data.removeWhere((e) => [" ", "\t", "\n"].contains(e));
    }
    MatchInfo counter = new MatchInfo();
    MatchInfo tmp;

    counter.matchRule = null;

    var i = 0;
    do {
      tmp = _check((data as List).sublist(counter.counter), new MatchInfo(), checkChild);
      tmp.matchRule = this;
      if (tmp.match) {
        if (tmp.counter > 0) i++;
        counter << tmp;
        counter.matchData = (counter.matchData == null) ? tmp.matchData: counter.matchData.addAll(tmp.matchData);
        tmp.matchRule = this;
        counter.child.add(tmp);
      } else {
        break;
      }
    } while(tmp.match && tmp.counter > 0 && continueCheck(i, this.quantifier, this.quantity) && counter.counter < data.length);
    if (!matchQuantifier(i, this.quantifier, this.quantity))
      counter.counter = MatchInfo.MATCH_FAILED;
    return counter;
  }

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

  String toString() {
    var s = "[Rules (${this.name})] quantifior: ${this.quantifier}, quantity: ${this.quantity}, nbChild: ${this._child.length}\n";
    for (var r in this._child) {
      if (r != this)
        s += " - " + r.toString();
      else
        s += " - [Rules (${this.name})] quantifior: ${this.quantifier}, quantity: ${this.quantity}, nbChild: ${this._child.length}\n";
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
    t._child = new List.from(this._child);
    return t;
  }
}