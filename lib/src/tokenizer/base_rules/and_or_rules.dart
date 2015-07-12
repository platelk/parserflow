part of parserflow;

class Or extends Rules {
  Or([List<Rules> r]) : super("Or") {
    if (r != null)
    this._child.addAll(r);
  }

  MatchInfo _checkChild(List data) {
    MatchInfo counter = new MatchInfo()..matchRule = this;
    MatchInfo tmp;

    for (Rules r in _child) {
      tmp = r.check(data);
      counter.child.add(tmp);
      if (tmp.match == true) {
        counter << tmp;
        return counter;
      }
    }
    counter.counter = MatchInfo.MATCH_FAILED;
    return counter;
  }

  Rules operator|(Rules r) {
    var tmp = this.clone();
    tmp._child.add(r);
    return tmp;
  }

  Rules _clone() {
    return new Or();
  }
}

class And extends Rules {
  And([List<Rules> r]) : super("And") {
    if (r != null)
      this._child.addAll(r);
  }

  Rules _clone() {
    return new And();
  }
}