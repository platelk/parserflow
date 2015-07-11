part of parserflow;

class Or extends Rules {
  Or(List<Rules> r) : super("Or") {
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
}

class And extends Rules {
  And(List<Rules> r) : super("And") {
    this._child.addAll(r);
  }
}