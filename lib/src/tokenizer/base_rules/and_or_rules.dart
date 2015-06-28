part of parserflow;

class Or extends Rules {
  Or(List<Rules> r) : super("Or") {
    this._child.addAll(r);
  }

  MatchInfo _checkChild(List data) {
    MatchInfo counter = new MatchInfo(counter: MatchInfo.MATCH_FAILED);
    MatchInfo tmp;

    for (Rules r in _child) {
      tmp = r.check(data);
      print("=> tmp: ${tmp.counter}");
      if (tmp.match == true)
        return tmp;
    }
    return counter;
  }
}

class And extends Rules {
  And(List<Rules> r) : super("And") {
    this._child.addAll(r);
  }
}